//
//  MovieTrailerApp.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

@main
struct MovieTrailerApp: App {
    
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            appCoordinator.start()
                .onOpenURL { url in
                    appCoordinator.handleDeepLink(url)
                }
        }
    }
}
