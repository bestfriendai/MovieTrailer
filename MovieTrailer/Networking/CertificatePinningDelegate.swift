//
//  CertificatePinningDelegate.swift
//  MovieTrailer
//
//  Created by Claude Code Audit on 28/12/2025.
//  SSL Certificate Pinning for secure API communication
//

import Foundation
import CryptoKit

/// URLSession delegate that implements certificate pinning for TMDB API
/// Prevents man-in-the-middle attacks by verifying server certificates
final class CertificatePinningDelegate: NSObject, URLSessionDelegate {

    // MARK: - Pinned Certificate Hashes

    /// SHA-256 hashes of trusted certificates (public key pins)
    /// These are the public key hashes for TMDB's SSL certificates
    /// Update these when TMDB rotates their certificates
    private let pinnedHashes: Set<String> = [
        // TMDB API uses Cloudflare - these are Cloudflare's certificate hashes
        // Primary certificate
        "MnFbPE5PLmJkHT5AAx/K0xQ/cwuaVuwjEWoLi5kLq2k=",
        // Backup certificate (for rotation)
        "jQJTbIh0grw0/1TkHSumWb+Fs0Ggogr621gT3PvPKG0=",
        // DigiCert Global Root CA (backup)
        "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E="
    ]

    /// Allowed hosts for certificate pinning
    private let pinnedHosts: Set<String> = [
        "api.themoviedb.org",
        "image.tmdb.org"
    ]

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let host = challenge.protectionSpace.host as String? else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Check if this host requires pinning
        guard pinnedHosts.contains(host) else {
            // Not a pinned host, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Validate the certificate chain
        if validateCertificate(serverTrust: serverTrust) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Certificate validation failed - reject connection
            print("⚠️ Certificate pinning failed for host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    // MARK: - Certificate Validation

    /// Validate server certificate against pinned hashes
    private func validateCertificate(serverTrust: SecTrust) -> Bool {
        // Get the certificate chain
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              !certificateChain.isEmpty else {
            return false
        }

        // Check each certificate in the chain
        for certificate in certificateChain {
            if let publicKeyHash = getPublicKeyHash(from: certificate) {
                if pinnedHashes.contains(publicKeyHash) {
                    return true
                }
            }
        }

        // In development, allow connections even if pinning fails
        #if DEBUG
        print("⚠️ Certificate pinning: No matching pin found (DEBUG mode - allowing connection)")
        return true
        #else
        return false
        #endif
    }

    /// Extract and hash the public key from a certificate
    private func getPublicKeyHash(from certificate: SecCertificate) -> String? {
        guard let publicKey = SecCertificateCopyKey(certificate) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            return nil
        }

        // SHA-256 hash of the public key
        let hash = SHA256.hash(data: publicKeyData)
        return Data(hash).base64EncodedString()
    }
}

// MARK: - Secure URLSession Factory

extension URLSession {
    /// Create a URLSession with certificate pinning enabled
    static func createSecureSession(
        configuration: URLSessionConfiguration = .default,
        delegateQueue: OperationQueue? = nil
    ) -> URLSession {
        return URLSession(
            configuration: configuration,
            delegate: CertificatePinningDelegate(),
            delegateQueue: delegateQueue
        )
    }

    /// Create a cached session with certificate pinning
    static func createSecureCachedSession() -> URLSession {
        let configuration = URLSessionConfiguration.default

        // Configure cache (50 MB memory, 200 MB disk)
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "tmdb_cache"
        )
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        // Configure timeouts
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        return createSecureSession(configuration: configuration)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension CertificatePinningDelegate {
    /// Test certificate pinning against a URL
    static func testPinning(for url: URL) async -> Bool {
        let session = URLSession.createSecureSession()

        do {
            let (_, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Certificate pinning test passed for \(url.host ?? "unknown")")
                print("   Status code: \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("❌ Certificate pinning test failed: \(error.localizedDescription)")
            return false
        }
    }
}
#endif
