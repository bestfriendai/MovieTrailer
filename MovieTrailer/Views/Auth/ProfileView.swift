//
//  ProfileView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  User profile and account management view
//

import SwiftUI
import Kingfisher

struct ProfileView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @ObservedObject private var firestoreService = FirestoreService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showSignIn = false
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile header
                        profileHeader

                        // Account section
                        accountSection

                        // Sync section
                        if authManager.authState.isAuthenticated {
                            syncSection
                        }

                        // Guest upgrade prompt
                        if authManager.authState.isGuest {
                            guestUpgradeSection
                        }

                        // Danger zone
                        if authManager.authState.isAuthenticated {
                            dangerZone
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView {
                showSignIn = false
            }
        }
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                try? authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await authManager.deleteAccount()
                }
            }
        } message: {
            Text("This will permanently delete your account and all synced data. This action cannot be undone.")
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            if let user = authManager.authState.currentUser {
                if let photoURL = user.photoURL {
                    KFImage(photoURL)
                        .placeholder {
                            avatarPlaceholder(user.initials)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    avatarPlaceholder(user.initials)
                }

                VStack(spacing: 4) {
                    Text(user.displayName ?? "User")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Provider badge
                    HStack(spacing: 6) {
                        Image(systemName: user.authProvider.iconName)
                            .font(.caption)
                        Text("Signed in with \(user.authProvider.displayName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 4)
                }
            } else if authManager.authState.isGuest {
                avatarPlaceholder("G")

                VStack(spacing: 4) {
                    Text("Guest User")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Sign in to sync your data")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                avatarPlaceholder("?")

                Text("Not signed in")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 24)
    }

    private func avatarPlaceholder(_ initials: String) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)

            Text(initials)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Account")

            VStack(spacing: 0) {
                if authManager.authState.isAuthenticated || authManager.authState.isGuest {
                    // Sign out button
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.white)
                                .frame(width: 24)

                            Text("Sign Out")
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding()
                    }
                } else {
                    // Sign in button
                    Button {
                        showSignIn = true
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)

                            Text("Sign In")
                                .foregroundColor(.white)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding()
                    }
                }
            }
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Sync Section

    private var syncSection: some View {
        VStack(spacing: 0) {
            sectionHeader("Sync")

            VStack(spacing: 0) {
                // Sync status
                HStack {
                    Image(systemName: firestoreService.isSyncing ? "arrow.triangle.2.circlepath" : "checkmark.icloud")
                        .foregroundColor(firestoreService.isSyncing ? .yellow : .green)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(firestoreService.isSyncing ? "Syncing..." : "Synced")
                            .foregroundColor(.white)

                        if let lastSync = firestoreService.lastSyncDate {
                            Text("Last synced \(lastSync.formatted(.relative(presentation: .named)))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Spacer()

                    if firestoreService.isSyncing {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .padding()

                Divider()
                    .background(Color.white.opacity(0.1))

                // Manual sync button
                Button {
                    Task {
                        if let userId = authManager.authState.currentUser?.id {
                            let localData = UserSyncData.empty // Get from local storage
                            _ = try? await firestoreService.syncUserData(local: localData, for: userId)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Sync Now")
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding()
                }
            }
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Guest Upgrade Section

    private var guestUpgradeSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "icloud.and.arrow.up")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)

                Text("Upgrade Your Account")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("Sign in to sync your watchlist and preferences across all your devices")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            Button {
                showSignIn = true
            } label: {
                Text("Sign In or Create Account")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(spacing: 0) {
            sectionHeader("Danger Zone")

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)

                    Text("Delete Account")
                        .foregroundColor(.red)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding()
            }
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
