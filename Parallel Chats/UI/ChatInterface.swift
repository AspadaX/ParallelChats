//
//  ChatInterface.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/19.
//

import SwiftUI
import AppKit

/// a struct that is intended to enable floating window
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> ()
    
    func makeNSView(context: Context) -> some NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            if let window = nsView.window {
                self.callback(window)
            }
        }
        
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
}

/// define how the window behaves
/// for now, we support floating over and displaying tabs by default
extension View {
    func configureWindow() -> some View {
        self.background(
            WindowAccessor {
                window in
                window.level = .floating
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            }
        )
    }
    
    func configureForTabs() -> some View {
        self.background(
            WindowAccessor {
                window in
                window.tabbingMode = .preferred
            }
        )
    }
}

public struct ChatInterface: View {
    
    @State private var messageText: String = ""
    @ObservedObject var chatAPI: ChatAPI
    @State private var conversation: Conversation;
    
    public init(chatAPI: ChatAPI) {
        self.chatAPI = chatAPI
        self.conversation = Conversation()
    }
    
    public var body: some View {
        VStack {
            // display the historical messages
            ScrollViewReader {
                scrollViewProxy in
                ScrollView {
                    ForEach(chatAPI.messagesInUI) {
                        message in
                        createMessageBubble(message: message)
                    }
                }
                    .onChange(of: chatAPI.messagesInUI) {
                        oldMessages, newMessages in
                        if let lastMessage = newMessages.last {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
            }
            
            // divide the historical messages and the input bar
            Divider()
            
            // input ui
            HStack {
                TextField("Enter message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(
                    action: {
                        sendMessage()
                    }
                ) {
                    Text("Send")
                }
                    .padding(.leading, 10)
            }
                .padding()
        }
            .navigationTitle("Parallel Chat")
            .configureForTabs()
    }
    
    private func createMessageBubble(message: Message) -> some View {
        return HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color.blue : Color.green)
                .foregroundColor(.white)
                .cornerRadius(20)
                .textSelection(.enabled)
            
            if message.role == .assistant {
                Spacer()
            }
        }
            .padding(.horizontal)
    }
    
    private func sendMessage() {
        Task {
            do {
                var tempConversation = conversation
                let messageToSend = messageText
                messageText = ""
                
                try await chatAPI.sendMessage(
                    message: Message(
                        id: UUID().uuidString,
                        role: .user,
                        content: messageToSend
                    ),
                    conversation: &tempConversation,
                    model: UserDefaults.standard.string(forKey: "modelName")!
                )
                
                conversation = tempConversation
                
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
}
