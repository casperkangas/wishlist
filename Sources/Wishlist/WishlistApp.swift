//  WishlistApp.swift
//  Entry point — sets up the app window and injects the shared WishStore.

import SwiftUI

@main
struct WishlistApp: App {
    @State private var store = WishStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 620)
        .commands {
            CommandGroup(replacing: .newItem) {
                // Handled inside the app via toolbar
            }
        }
    }
}
