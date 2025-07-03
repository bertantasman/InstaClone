//
//  Message.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 30.05.2025.
//

import Foundation
import FirebaseFirestore

struct Message {
    let senderID: String
    let receiverID: String
    let text: String
    let timestamp: Timestamp

    init(senderID: String, receiverID: String, text: String, timestamp: Timestamp) {
        self.senderID = senderID
        self.receiverID = receiverID
        self.text = text
        self.timestamp = timestamp
    }

    init?(document: [String: Any]) {
        guard let senderID = document["senderID"] as? String,
              let receiverID = document["receiverID"] as? String,
              let text = document["text"] as? String,
              let timestamp = document["timestamp"] as? Timestamp else {
            return nil
        }
        self.senderID = senderID
        self.receiverID = receiverID
        self.text = text
        self.timestamp = timestamp
    }
}
