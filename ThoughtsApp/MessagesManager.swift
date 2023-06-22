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
    
    // File URL for storing messages
    private let messagesFileURL: URL
    
    init() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.messagesFileURL = documentsURL.appendingPathComponent("messages.json")
        
        getMessages()
    }
    
    // Retrieve messages from the file
    func getMessages() {
        if FileManager.default.fileExists(atPath: messagesFileURL.path),
           let data = try? Data(contentsOf: messagesFileURL) {
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
    
    // Store messages in the file
    private func storeMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: messagesFileURL, options: .atomic)
            print("Messages stored successfully.")
        } catch {
            print("Failed to store messages: \(error)")
        }
    }
    
    // Add a message
    func sendMessage(text: String) {
        let newMessage = Message(id: "\(UUID())", text: text, received: false, timestamp: Date(), tags: [])
        messages.append(newMessage)
        messages.sort { $0.timestamp < $1.timestamp }
        
        storeMessages()
        
        print("New message added: \(newMessage)")
    }
}
