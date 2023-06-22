//
//  Message.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var received: Bool
    var timestamp: Date
    var tags: [String] 
}








