//
//  ContentView.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/18.
//

import SwiftUI
import OpenAI

struct ContentView: View {
    
    @ObservedObject var configurationManager: ConfigurationManager
    
    var body: some View {
        
        let client = OpenAI(
            configuration: configurationManager.configuration
        )
        
        let chatAPI = ChatAPI(
            openAIClient: client
        )
        
        ChatInterface(
            chatAPI: chatAPI
        )
    }
}

#Preview {
    let configurationManager = ConfigurationManager()
    return ContentView(configurationManager: configurationManager)
}
