//  WishlistApp.swift

import SwiftUI
import AppKit

@main
struct WishlistApp: App {
    @State private var store = WishStore()

    init() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 960, height: 640)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

func applyWarmWindowBackground() {
    DispatchQueue.main.async {
        for window in NSApplication.shared.windows {
            // Noticeably warm tan — dark enough that cream cards pop against it
            window.backgroundColor = NSColor(
                red: 0.84, green: 0.80, blue: 0.74, alpha: 1.0
            )
            window.makeKeyAndOrderFront(nil)
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
