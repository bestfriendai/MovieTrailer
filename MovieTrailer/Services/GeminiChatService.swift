//
//  GeminiChatService.swift
//  MovieTrailer
//
//  Gemini AI + Full TMDB Integration + Session Memory
//  Dynamic actor/director search, streaming, runtime, genres, decades
//

import Foundation
import GoogleGenerativeAI

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var movies: [Movie]

    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        movies: [Movie] = []
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.movies = movies
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id && lhs.content == rhs.content && lhs.isStreaming == rhs.isStreaming
    }
}

// MARK: - Gemini Chat Service

@MainActor
final class GeminiChatService: ObservableObject {

    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isStreaming = false
    @Published var error: Error?

    private var model: GenerativeModel?
    private var chat: Chat?
    private let tmdbService = TMDBService.shared
    private let modelName = "gemini-2.0-flash-001"

    // Session memory - tracks context
    private var sessionContext: SessionContext = SessionContext()

    // MARK: - Session Context

    struct SessionContext {
        var lastMentionedMovies: [Movie] = []
        var lastSearchedActor: String?
        var lastSearchedDirector: String?
        var preferredGenres: Set<Int> = []
        var preferredDecade: Int?
        var preferredStreamingServices: [Int] = []
    }

    // MARK: - Streaming Services

    static let streamingServices: [(String, Int, [String])] = [
        ("Netflix", 8, ["netflix"]),
        ("Amazon Prime", 9, ["amazon", "prime", "prime video"]),
        ("Disney+", 337, ["disney", "disney+", "disney plus"]),
        ("Hulu", 15, ["hulu"]),
        ("HBO Max", 384, ["hbo", "hbo max", "max"]),
        ("Apple TV+", 350, ["apple tv", "apple tv+", "appletv"]),
        ("Paramount+", 531, ["paramount", "paramount+"]),
        ("Peacock", 386, ["peacock"]),
    ]

    // MARK: - Genre Mappings

    static let genres: [(String, Int, [String])] = [
        ("Action", 28, ["action", "explosive", "fights", "stunts"]),
        ("Comedy", 35, ["comedy", "funny", "hilarious", "laugh", "comedies"]),
        ("Drama", 18, ["drama", "dramatic", "emotional"]),
        ("Horror", 27, ["horror", "scary", "terrifying", "creepy", "spooky"]),
        ("Science Fiction", 878, ["sci-fi", "science fiction", "space", "futuristic", "aliens"]),
        ("Romance", 10749, ["romance", "romantic", "love story", "rom-com"]),
        ("Thriller", 53, ["thriller", "suspense", "tense", "suspenseful"]),
        ("Animation", 16, ["animated", "animation", "cartoon", "pixar"]),
        ("Documentary", 99, ["documentary", "documentaries"]),
        ("Fantasy", 14, ["fantasy", "magical", "wizards", "dragons"]),
        ("Crime", 80, ["crime", "heist", "gangster", "mob"]),
        ("Mystery", 9648, ["mystery", "whodunit", "detective"]),
        ("War", 10752, ["war", "military", "battle"]),
        ("Family", 10751, ["family", "kids", "children", "family-friendly"]),
        ("Adventure", 12, ["adventure", "quest", "journey"]),
    ]

    // MARK: - Init

    init(userPreferences: UserPreferences = .shared) {
        setupModel()
        addWelcomeMessage()
    }

    private func setupModel() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String,
              !apiKey.isEmpty else { return }

        let config = GenerationConfig(
            temperature: 0.9,
            maxOutputTokens: 400
        )

        model = GenerativeModel(
            name: modelName,
            apiKey: apiKey,
            generationConfig: config,
            systemInstruction: ModelContent(role: "system", parts: [.text(systemPrompt)])
        )

        // Initialize chat with history for memory
        chat = model?.startChat()
    }

    private var systemPrompt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let today = dateFormatter.string(from: Date())

        return """
        You are a friendly, knowledgeable movie expert AI assistant. Today is \(today).

        Your capabilities:
        - Recommend movies based on genres, actors, directors, decades, streaming services
        - Remember what the user has asked about in this conversation
        - Provide personalized suggestions based on the user's preferences
        - Give brief, enthusiastic responses (2-3 sentences max)

        When movies are found, introduce them briefly. Don't list all movies - just give a quick intro.
        If the user asks about "more like that" or "similar", refer to previous recommendations.
        Be conversational and helpful. Use the user's name if they provide it.
        """
    }

    private func addWelcomeMessage() {
        messages.append(ChatMessage(
            role: .assistant,
            content: "Hey! I'm your movie expert. I can find films by actor, director, genre, decade, or streaming service. Try:\n• \"Movies with Tom Hanks\"\n• \"Nolan films\"\n• \"90s action on Netflix\"\n• \"Something like that\" (after I show you movies)"
        ))
    }

    // MARK: - Send Message

    func sendMessage(_ text: String) async {
        guard model != nil else {
            error = NSError(domain: "Chat", code: -1, userInfo: [NSLocalizedDescriptionKey: "API not configured"])
            return
        }

        // Add user message
        messages.append(ChatMessage(role: .user, content: text))

        // Create assistant placeholder
        let assistantId = UUID()
        messages.append(ChatMessage(id: assistantId, role: .assistant, content: "", isStreaming: true))

        isLoading = true
        isStreaming = true

        // Analyze query and fetch movies
        let (movies, searchDescription) = await analyzeAndFetch(text)

        // Update session context
        if !movies.isEmpty {
            sessionContext.lastMentionedMovies = movies
        }

        // Generate response with Gemini (with conversation memory)
        let response = await generateResponse(for: text, movies: movies, searchDescription: searchDescription)

        // Update message
        if let index = messages.firstIndex(where: { $0.id == assistantId }) {
            messages[index].content = response
            messages[index].isStreaming = false
            messages[index].movies = movies
        }

        isLoading = false
        isStreaming = false
    }

    func clearChat() {
        messages.removeAll()
        sessionContext = SessionContext()
        chat = model?.startChat() // Reset chat history
        addWelcomeMessage()
    }

    // MARK: - Analyze and Fetch

    private func analyzeAndFetch(_ query: String) async -> ([Movie], String) {
        let q = query.lowercased()

        // Check for "more like that" / "similar" references
        if q.contains("more like") || q.contains("similar") || q.contains("like that") ||
           q.contains("another") || q.contains("more of") {
            if let firstMovie = sessionContext.lastMentionedMovies.first {
                return await fetchSimilarMovies(to: firstMovie)
            }
        }

        // Detect person names (actors/directors) using TMDB search
        if let personResult = await detectAndSearchPerson(in: query) {
            return personResult
        }

        // Detect streaming service
        var streamingIds: [Int] = []
        for (_, id, keywords) in Self.streamingServices {
            for keyword in keywords {
                if q.contains(keyword) {
                    streamingIds.append(id)
                    break
                }
            }
        }

        // Detect genres (multiple)
        var genreIds: [Int] = []
        var genreNames: [String] = []
        for (name, id, keywords) in Self.genres {
            for keyword in keywords {
                if q.contains(keyword) && !genreIds.contains(id) {
                    genreIds.append(id)
                    genreNames.append(name)
                    break
                }
            }
        }

        // Detect year
        var year: Int?
        let yearPattern = #"\b(19\d{2}|20[0-2]\d)\b"#
        if let yearRegex = try? NSRegularExpression(pattern: yearPattern),
           let match = yearRegex.firstMatch(in: q, range: NSRange(q.startIndex..., in: q)),
           let range = Range(match.range, in: q) {
            year = Int(q[range])
        }

        // Detect decade
        var decade: Int?
        if q.contains("80s") || q.contains("eighties") { decade = 1980 }
        else if q.contains("90s") || q.contains("nineties") { decade = 1990 }
        else if q.contains("2000s") || q.contains("aughts") { decade = 2000 }
        else if q.contains("2010s") { decade = 2010 }
        else if q.contains("classic") || q.contains("old") { decade = 1980 }

        // Detect runtime
        var maxRuntime: Int?
        var minRuntime: Int?
        if q.contains("short") || q.contains("quick") || q.contains("under 90") {
            maxRuntime = 90
        } else if q.contains("long") || q.contains("epic") || q.contains("3 hour") {
            minRuntime = 150
        }

        // Detect special intents
        if q.contains("theatre") || q.contains("theater") || q.contains("now playing") ||
           q.contains("in cinema") || q.contains("out now") {
            return await fetchNowPlaying(genres: genreIds)
        }

        if q.contains("upcoming") || q.contains("coming soon") || q.contains("releasing") {
            return await fetchUpcoming(genres: genreIds)
        }

        if q.contains("trending") || q.contains("popular right now") || q.contains("hot") {
            return await fetchTrending(genres: genreIds)
        }

        if q.contains("top rated") || q.contains("best") || q.contains("highest rated") {
            return await fetchTopRated(genres: genreIds)
        }

        if q.contains("hidden gem") || q.contains("underrated") || q.contains("overlooked") {
            return await fetchHiddenGems(genres: genreIds)
        }

        // Build discover filter
        if !genreIds.isEmpty || year != nil || decade != nil || !streamingIds.isEmpty ||
           maxRuntime != nil || minRuntime != nil {
            return await fetchWithFilters(
                genres: genreIds,
                genreNames: genreNames,
                year: year,
                decade: decade,
                streamingIds: streamingIds,
                maxRuntime: maxRuntime,
                minRuntime: minRuntime
            )
        }

        // Default: trending
        return await fetchTrending(genres: [])
    }

    // MARK: - Person Detection with TMDB Search

    private func detectAndSearchPerson(in query: String) async -> ([Movie], String)? {
        let q = query.lowercased()

        // Common patterns for actor/director mentions
        let patterns = [
            "movies with ",
            "films with ",
            "starring ",
            "with actor ",
            "featuring ",
            "directed by ",
            "by director ",
            "from director ",
            " movies",
            " films",
            "'s movies",
            "'s films"
        ]

        // Try to extract person name
        var personName: String?
        var isDirector = false

        // Check for director keywords
        if q.contains("directed by") || q.contains("director") || q.contains("by ") {
            isDirector = true
        }

        // Extract name from patterns
        for pattern in patterns {
            if let range = q.range(of: pattern) {
                if pattern.hasPrefix("directed") || pattern.hasPrefix("by director") || pattern.hasPrefix("from director") {
                    let afterPattern = String(q[range.upperBound...])
                    personName = extractName(from: afterPattern)
                    isDirector = true
                } else if pattern.hasSuffix("movies") || pattern.hasSuffix("films") {
                    let beforePattern = String(q[..<range.lowerBound])
                    personName = extractName(from: beforePattern, fromEnd: true)
                } else {
                    let afterPattern = String(q[range.upperBound...])
                    personName = extractName(from: afterPattern)
                }
                if personName != nil { break }
            }
        }

        guard let name = personName, name.count >= 3 else { return nil }

        // Search TMDB for the person
        do {
            let searchResult = try await tmdbService.searchPerson(query: name)
            guard let person = searchResult.results.first else { return nil }

            // Update session context
            if person.isDirector || isDirector {
                sessionContext.lastSearchedDirector = person.name
            } else {
                sessionContext.lastSearchedActor = person.name
            }

            // Fetch their movies
            let movieCredits = try await tmdbService.fetchPersonMovieCredits(id: person.id)

            let movies: [Movie]
            let description: String

            if person.isDirector || isDirector {
                // Get directing credits - break up to avoid compiler timeout
                let directedCredits = movieCredits.crew.filter { $0.job.lowercased() == "director" }
                let sortedCredits = directedCredits.sorted { $0.popularity > $1.popularity }
                let topCredits = Array(sortedCredits.prefix(10))
                movies = topCredits.map { credit in
                    Movie(
                        id: credit.id,
                        title: credit.title,
                        overview: "",
                        posterPath: credit.posterPath,
                        backdropPath: nil,
                        releaseDate: credit.releaseDate,
                        voteAverage: credit.voteAverage,
                        voteCount: 0,
                        popularity: credit.popularity,
                        genreIds: [],
                        adult: false,
                        originalLanguage: "",
                        originalTitle: credit.title,
                        video: false
                    )
                }
                description = "movies directed by \(person.name)"
            } else {
                // Get acting credits
                movies = movieCredits.cast
                    .sorted { $0.popularity > $1.popularity }
                    .prefix(10)
                    .map { $0.toMovie() }
                description = "movies with \(person.name)"
            }

            return (movies, description)
        } catch {
            print("Person search error: \(error)")
            return nil
        }
    }

    private func extractName(from text: String, fromEnd: Bool = false) -> String? {
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'s", with: "")
            .components(separatedBy: CharacterSet.alphanumerics.inverted.subtracting(.whitespaces))
            .joined()
            .trimmingCharacters(in: .whitespaces)

        // Take first 2-3 words as name
        let words = cleaned.split(separator: " ").map(String.init)
        if fromEnd {
            let nameWords = words.suffix(3)
            if nameWords.count >= 1 {
                return nameWords.joined(separator: " ")
            }
        } else {
            let nameWords = words.prefix(3)
            if nameWords.count >= 1 {
                return nameWords.joined(separator: " ")
            }
        }
        return nil
    }

    // MARK: - Fetch Methods

    private func fetchSimilarMovies(to movie: Movie) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchSimilarMovies(for: movie.id)
            return (Array(response.results.prefix(10)), "movies similar to \(movie.title)")
        } catch {
            return ([], "")
        }
    }

    private func fetchNowPlaying(genres: [Int]) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchNowPlaying(page: 1)
            var movies = response.results
            if !genres.isEmpty {
                movies = movies.filter { movie in
                    genres.contains { movie.genreIds.contains($0) }
                }
            }
            return (Array(movies.prefix(10)), "currently in theaters")
        } catch {
            return ([], "")
        }
    }

    private func fetchUpcoming(genres: [Int]) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchUpcoming(page: 1)
            var movies = response.results
            if !genres.isEmpty {
                movies = movies.filter { movie in
                    genres.contains { movie.genreIds.contains($0) }
                }
            }
            return (Array(movies.prefix(10)), "coming soon")
        } catch {
            return ([], "")
        }
    }

    private func fetchTrending(genres: [Int]) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            var movies = response.results
            if !genres.isEmpty {
                movies = movies.filter { movie in
                    genres.contains { movie.genreIds.contains($0) }
                }
            }
            return (Array(movies.prefix(10)), "trending now")
        } catch {
            return ([], "")
        }
    }

    private func fetchTopRated(genres: [Int]) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchTopRated(page: 1)
            var movies = response.results
            if !genres.isEmpty {
                movies = movies.filter { movie in
                    genres.contains { movie.genreIds.contains($0) }
                }
            }
            return (Array(movies.prefix(10)), "top rated of all time")
        } catch {
            return ([], "")
        }
    }

    private func fetchHiddenGems(genres: [Int]) async -> ([Movie], String) {
        do {
            let response = try await tmdbService.fetchHiddenGems(page: 1)
            var movies = response.results
            if !genres.isEmpty {
                movies = movies.filter { movie in
                    genres.contains { movie.genreIds.contains($0) }
                }
            }
            return (Array(movies.prefix(10)), "hidden gems")
        } catch {
            return ([], "")
        }
    }

    private func fetchWithFilters(
        genres: [Int],
        genreNames: [String],
        year: Int?,
        decade: Int?,
        streamingIds: [Int],
        maxRuntime: Int?,
        minRuntime: Int?
    ) async -> ([Movie], String) {
        do {
            var filters = DiscoverFilters()

            if !genres.isEmpty {
                filters.genres = genres
            }

            if let year = year {
                filters.yearMin = year
                filters.yearMax = year
            } else if let decade = decade {
                filters.yearMin = decade
                filters.yearMax = decade + 9
            }

            if !streamingIds.isEmpty {
                filters.withWatchProviders = streamingIds
                filters.watchRegion = "US"
                filters.watchMonetizationType = .flatrate
            }

            if let maxRuntime = maxRuntime {
                filters.runtimeMax = maxRuntime
            }
            if let minRuntime = minRuntime {
                filters.runtimeMin = minRuntime
            }

            filters.voteCountMin = 50
            filters.sortBy = .popularityDesc

            let response = try await tmdbService.discoverMovies(filters: filters)

            // Build description
            var parts: [String] = []
            if !genreNames.isEmpty {
                parts.append(genreNames.joined(separator: " & ").lowercased())
            }
            parts.append("movies")

            if !streamingIds.isEmpty {
                let serviceNames = streamingIds.compactMap { id in
                    Self.streamingServices.first { $0.1 == id }?.0
                }
                if !serviceNames.isEmpty {
                    parts.append("on \(serviceNames.joined(separator: " and "))")
                }
            }

            if let year = year {
                parts.append("from \(year)")
            } else if let decade = decade {
                parts.append("from the \(decade)s")
            }

            if maxRuntime != nil {
                parts.append("(short)")
            } else if minRuntime != nil {
                parts.append("(epic length)")
            }

            return (Array(response.results.prefix(10)), parts.joined(separator: " "))
        } catch {
            return ([], "")
        }
    }

    // MARK: - Generate Response with Memory

    private func generateResponse(for userQuery: String, movies: [Movie], searchDescription: String) async -> String {
        guard let chat = chat else { return "Here's what I found:" }

        if movies.isEmpty {
            return "I couldn't find movies matching that. Try:\n• \"Action movies on Netflix\"\n• \"Movies with [actor name]\"\n• \"90s comedies\"\n• \"Films by Nolan\""
        }

        let movieList = movies.prefix(5).map { "\($0.title) (\($0.releaseYear ?? ""))" }.joined(separator: ", ")

        // Build context from session
        var contextInfo = ""
        if let actor = sessionContext.lastSearchedActor {
            contextInfo += " Recently discussed: \(actor)."
        }
        if let director = sessionContext.lastSearchedDirector {
            contextInfo += " Recently discussed director: \(director)."
        }

        let prompt = """
        User asked: "\(userQuery)"
        I found these \(searchDescription): \(movieList)\(contextInfo)

        Write a brief, friendly 1-2 sentence response introducing these movies. Be enthusiastic but concise. If there's a standout movie, mention it. Remember this is a conversation - refer to context if relevant.
        """

        do {
            let result = try await chat.sendMessage(prompt)
            return result.text ?? "Here are some great \(searchDescription):"
        } catch {
            return "Here are some \(searchDescription) you might enjoy:"
        }
    }
}
