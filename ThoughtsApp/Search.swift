//
//  Search.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 23/06/2023.
//

import Foundation

class SearchManager: ObservableObject {
    @Published var searchQuery = ""
    
    func filterMessages(_ messages: [Message]) -> [Message] {
        if searchQuery.isEmpty {
            return messages
        } else {
            return messages.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
}
