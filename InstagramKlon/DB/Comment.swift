//
//  comments.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 13.05.2025.
//

import Foundation
import FirebaseFirestore

struct Comment {
    let id: String
    let userID: String
    let postID: String
    let username: String
    let commentText: String
    let timestamp: Timestamp
    let profileImageURL: String

    
    var timestampString: String {
        let date = timestamp.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }

    
    init?(document: [String: Any]) {
        guard let id = document["id"] as? String,
              let userID = document["userID"] as? String,
              let postID = document["postID"] as? String,
              let username = document["username"] as? String,
              let commentText = document["commentText"] as? String,
              let timestamp = document["timestamp"] as? Timestamp,
              let profileImageURL = document["profileImageURL"] as? String else {
                  return nil
              }

        self.id = id
        self.userID = userID
        self.postID = postID
        self.username = username
        self.commentText = commentText
        self.timestamp = timestamp
        self.profileImageURL = profileImageURL
    }
}
