//
//  MessagesManager.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import Foundation

class MessagesManager: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    // UserDefaults key for storing messages
    private let messagesUserDefaultsKey = "messages"
    
    init() {
        getMessages()
    }
    
    // Retrieve messages from UserDefaults
    func getMessages() {
        if let data = UserDefaults.standard.data(forKey: messagesUserDefaultsKey) {
            if let storedMessages = try? JSONDecoder().decode([Message].self, from: data) {
                messages = storedMessages.sorted { $0.timestamp < $1.timestamp }
                
                // Get the ID of the last message
                if let id = messages.last?.id {
                    lastMessageId = id
                }
            }
        }
        print("Retrieved messages: \(messages)")
    }
    
    // Store messages in UserDefaults
    private func storeMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: messagesUserDefaultsKey)
            print("Messages stored successfully.")
        } catch {
            print("Failed to store messages: \(error)")
        }
    }
    
    // Add a message
    func sendMessage(text: String) {
        let newMessage = Message(id: "\(UUID())", text: text, received: false, timestamp: Date())
        messages.append(newMessage)
        messages.sort { $0.timestamp < $1.timestamp }
        
        storeMessages()
        
        print("New message added: \(newMessage)")
    }
    
    // Delete a message
    func deleteMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
            storeMessages()
            print("Message deleted: \(message)")
        }
    }
    
    // Update a message
    func updateMessage(_ message: Message, with newText: String) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].text = newText
            storeMessages()
            print("Message updated: \(message)")
        }
    }
}
