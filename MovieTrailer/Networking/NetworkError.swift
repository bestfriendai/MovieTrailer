//
//  NetworkError.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Custom error types for network operations
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case noData
    case unauthorized
    case rateLimitExceeded
    case serverError
    case unknown
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .unauthorized:
            return "Unauthorized - please check your API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded - please try again later"
        case .serverError:
            return "Server error - please try again later"
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was malformed or invalid"
        case .invalidResponse:
            return "The server returned an unexpected response"
        case .httpError(let statusCode):
            return "The server returned status code \(statusCode)"
        case .decodingError:
            return "The response data could not be parsed"
        case .networkError:
            return "A network connectivity issue occurred"
        case .noData:
            return "The server did not return any data"
        case .unauthorized:
            return "Your API key is missing or invalid"
        case .rateLimitExceeded:
            return "You have exceeded the API rate limit"
        case .serverError:
            return "The server encountered an internal error"
        case .unknown:
            return "The cause of the error is unknown"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please contact support"
        case .invalidResponse:
            return "Please try again later"
        case .httpError(let statusCode):
            if statusCode >= 500 {
                return "The server is experiencing issues. Please try again later"
            } else if statusCode == 404 {
                return "The requested resource was not found"
            } else {
                return "Please check your request and try again"
            }
        case .decodingError:
            return "Please update the app to the latest version"
        case .networkError:
            return "Please check your internet connection and try again"
        case .noData:
            return "Please try again"
        case .unauthorized:
            return "Please verify your TMDB API key in the app settings"
        case .rateLimitExceeded:
            return "Please wait a few minutes before trying again"
        case .serverError:
            return "Please try again in a few minutes"
        case .unknown:
            return "Please try again or contact support"
        }
    }
    
    // MARK: - User-Friendly Messages
    
    /// Short user-facing error message
    var userMessage: String {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError, .unknown:
            return "Something went wrong"
        case .httpError(let statusCode):
            if statusCode == 404 {
                return "Not found"
            } else if statusCode >= 500 {
                return "Server error"
            } else {
                return "Request failed"
            }
        case .networkError:
            return "No internet connection"
        case .noData:
            return "No data available"
        case .unauthorized:
            return "Invalid API key"
        case .rateLimitExceeded:
            return "Too many requests"
        case .serverError:
            return "Server error"
        }
    }
    
    /// Whether the error is recoverable by retrying
    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .rateLimitExceeded:
            return true
        case .httpError(let code):
            return code >= 500 || code == 429
        default:
            return false
        }
    }
    
    /// Whether the error requires user action
    var requiresUserAction: Bool {
        switch self {
        case .unauthorized:
            return true
        default:
            return false
        }
    }
}

// MARK: - HTTP Status Code Helpers

extension NetworkError {
    /// Create NetworkError from HTTP status code
    static func from(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 200...299:
            return .unknown // Should not happen for successful responses
        case 401:
            return .unauthorized
        case 429:
            return .rateLimitExceeded
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode)
        }
    }
}
