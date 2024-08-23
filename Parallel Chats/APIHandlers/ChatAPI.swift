//
//  ChatAPI.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/19.
//

import Foundation
import OpenAI

public struct Message {
    public var id: String = UUID().uuidString
    public var role: ChatQuery.ChatCompletionMessageParam.Role
    public var content: String
    public var createdAt: Date = .now
}

extension Message: Equatable, Codable, Hashable, Identifiable {}

public struct Conversation {
    public let id: String = UUID().uuidString
    public var messages: [Message] = []
    
    init() {}
    
    /// a method dedicated for adding a new message to the existing conversation
    public mutating func addNewMessage(message: Message) {
        self.messages.append(message)
    }
}

extension Conversation: Equatable, Identifiable {}

public final class ChatAPI: ObservableObject {
    
    /// this variable stores the message contents that will be shown in the UI
    /// however, each Message here represents a chunk.
    @Published var messagesInUI: [Message] = []
    
    public var openAIClient: OpenAIProtocol
    
    public init(openAIClient: OpenAIProtocol) {
        self.openAIClient = openAIClient
    }
    
    /// send user message to OpenAI and get the response
    @MainActor
    func sendMessage(message: Message, conversation: inout Conversation, model: String) async throws {
        
        // append the user message to the conversation history
        conversation.messages.append(message)
        
        // update the user message to the UI
        self.updateMessageInUI(message: message)

        do {
            var fullMessageContent = ""
            var temporaryMessage = Message(
                id: UUID().uuidString,
                role: .assistant,
                content: "",
                createdAt: .now
            )
            
            let query = ChatQuery(
                messages: conversation.messages.map {
                    message in
                    ChatQuery.ChatCompletionMessageParam(
                        role: message.role,
                        content: message.content
                    )!
                },
                model: model,
                stream: true
            )
            
            let stream: AsyncThrowingStream<ChatStreamResult, Error> = openAIClient.chatsStream(query: query)
            
            for try await partialChatResult in stream {
                
                let deltaContent = partialChatResult.choices.first?.delta.content
                let finishedReason = partialChatResult.choices.first?.finishReason
                
                if let deltaContent {
                    fullMessageContent += deltaContent
                    
                    temporaryMessage.content = fullMessageContent
                    
                    self.updateMessageInUI(message: temporaryMessage)
                }
                
                if finishedReason == ChatStreamResult.Choice.FinishReason.stop {
                    
                    let response = Message(
                        role: .assistant, content: temporaryMessage.content
                    )
                    
                    self.saveFullMessageToConversation(message: response, conversation: &conversation)
                }
            }
        } catch {
            print("Error streaming chat results: \(error)")
        }
    }
    
    /// update the message while it is streaming
    private func updateMessageInUI(message: Message) {
        if let index = self.messagesInUI.firstIndex(where: { $0.id == message.id }) {
            self.messagesInUI[index] = message
        } else {
            self.messagesInUI.append(message)
        }
    }
    
    /// retrieve the response and save it to the convesation
    @MainActor
    func saveFullMessageToConversation(
        message: Message,
        conversation: inout Conversation
    ) {
        conversation.addNewMessage(message: message)
    }
    
}
