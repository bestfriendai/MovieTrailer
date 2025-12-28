//
//  CertificatePinningDelegate.swift
//  MovieTrailer
//
//  Created by Claude Code Audit on 28/12/2025.
//  Implements SSL/TLS certificate pinning for secure API communication
//

import Foundation
import Security
import CryptoKit

/// URLSession delegate that implements certificate pinning for TMDB API
/// This prevents man-in-the-middle attacks by validating server certificates
final class CertificatePinningDelegate: NSObject, URLSessionDelegate {

    // MARK: - Configuration

    /// Pinned public key hashes for api.themoviedb.org (SHA-256)
    /// These are the SPKI (Subject Public Key Info) hashes
    /// Update these if TMDB rotates their certificates
    private static let pinnedPublicKeyHashes: Set<String> = [
        // TMDB uses Cloudflare, these are Cloudflare's root CA public key hashes
        // You should update these periodically as certificates rotate
        // DigiCert Global Root CA
        "r/mIkG3eEpVdm+u/ko/cwxzOMo1bk4TyHIlByibiA5E=",
        // DigiCert Global Root G2
        "i7WTqTvh0OioIruIfFR4kMPnBqrS2rdiVPl/s2uC/CY=",
        // Baltimore CyberTrust Root
        "Y9mvm0exBk1JoQ57f9Vm28jKo5lFm/woKcVxrYxu80o=",
        // Cloudflare Inc ECC CA-3
        "Ao0HYvL48dRY9gLgj7NMjVs5gXJHLF5LbFqQqTOqbzQ=",
        // Let's Encrypt ISRG Root X1
        "C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=",
        // Backup: GlobalSign Root CA - R3
        "cGuxAXyFXFkWm61cF4HPWX8S0srS9j0aSqN0k4AP+4A=",
    ]

    /// Domains to apply pinning
    private static let pinnedDomains: Set<String> = [
        "api.themoviedb.org",
        "image.tmdb.org"
    ]

    /// Whether to enforce pinning (disable in development if needed)
    private let enforcePinning: Bool

    // MARK: - Initialization

    init(enforcePinning: Bool = true) {
        self.enforcePinning = enforcePinning
        super.init()
    }

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

        // Check if this domain should be pinned
        let shouldPin = Self.pinnedDomains.contains { host.hasSuffix($0) }

        guard shouldPin else {
            // Not a pinned domain, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Validate the certificate chain
        let policies = [SecPolicyCreateSSL(true, host as CFString)]
        SecTrustSetPolicies(serverTrust, policies as CFTypeRef)

        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)

        guard isValid else {
            print("❌ Certificate validation failed for \(host): \(error?.localizedDescription ?? "Unknown error")")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract and validate public key hash
        guard validatePublicKeyPinning(serverTrust: serverTrust, host: host) else {
            if enforcePinning {
                print("❌ Certificate pinning failed for \(host)")
                completionHandler(.cancelAuthenticationChallenge, nil)
            } else {
                print("⚠️ Certificate pinning would have failed for \(host) (enforcement disabled)")
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            }
            return
        }

        print("✅ Certificate pinning validated for \(host)")
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }

    // MARK: - Private Methods

    /// Validate that at least one certificate in the chain matches our pinned hashes
    private func validatePublicKeyPinning(serverTrust: SecTrust, host: String) -> Bool {
        let certificateCount = SecTrustGetCertificateCount(serverTrust)

        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index) else {
                continue
            }

            // Get the public key from the certificate
            guard let publicKey = SecCertificateCopyKey(certificate) else {
                continue
            }

            // Get the public key data
            guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
                continue
            }

            // Compute SHA-256 hash of the public key
            let hash = computeSHA256Hash(of: publicKeyData)

            if Self.pinnedPublicKeyHashes.contains(hash) {
                return true
            }
        }

        // Log the actual hashes for debugging (in development only)
        #if DEBUG
        print("⚠️ No matching pins found for \(host). Server certificate hashes:")
        for index in 0..<certificateCount {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, index),
               let publicKey = SecCertificateCopyKey(certificate),
               let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? {
                let hash = computeSHA256Hash(of: publicKeyData)
                print("   Certificate \(index): \(hash)")
            }
        }
        #endif

        return false
    }

    /// Compute SHA-256 hash of data and return as Base64 string
    private func computeSHA256Hash(of data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
    }
}

// MARK: - URLSession Extension for Pinned Sessions

extension URLSession {
    /// Create a URLSession with certificate pinning enabled
    static func pinnedSession(
        configuration: URLSessionConfiguration = .default,
        enforcePinning: Bool = true
    ) -> URLSession {
        let delegate = CertificatePinningDelegate(enforcePinning: enforcePinning)
        return URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
    }
}

// MARK: - Certificate Pinning Error

enum CertificatePinningError: LocalizedError {
    case pinningFailed(host: String)
    case invalidCertificate
    case noPublicKey

    var errorDescription: String? {
        switch self {
        case .pinningFailed(let host):
            return "Certificate pinning failed for \(host)"
        case .invalidCertificate:
            return "Invalid server certificate"
        case .noPublicKey:
            return "Could not extract public key from certificate"
        }
    }
}
