//
//  chats.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 28.05.2025.
//

import FirebaseFirestore

struct Chat {
    let id: String
    let lastMessage: String
    let participants: [String]
    let timestamp: Date
    var imageURL: String?  // Profil fotoğrafı için opsiyonel
    
    init?(document: [String: Any], id: String) {
        guard let lastMessage = document["lastMessage"] as? String,
              let participants = document["participants"] as? [String],
              let timestamp = document["timestamp"] as? Timestamp else {
            return nil
        }
        
        self.id = id
        self.lastMessage = lastMessage
        self.participants = participants
        self.timestamp = timestamp.dateValue()
        self.imageURL = document["imageURL"] as? String
    }
}
