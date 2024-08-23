//
//  Parallel_ChatsApp.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/18.
//

import SwiftUI

@main
struct ParallelChatsApp: App {
    
    @StateObject var configurationManager = ConfigurationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(configurationManager: configurationManager)
        }
            .commands {
                CommandGroup(replacing: CommandGroupPlacement.appSettings) {
                    Button(action: {
                        openSettingsView()
                        configurationManager.updateConfiguration()
                    }) {
                        Text("Settings")
                    }
                        .keyboardShortcut(",", modifiers: .command)
                }
            }
    }
    
    private func openSettingsView() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings")
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.contentView = NSHostingView(
            rootView: SettingsView(configurationManager: configurationManager)
        )
        settingsWindow.makeKeyAndOrderFront(nil)
    }
}
