//
//  data.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import Foundation

class data{
    var id:Int?
    var photo:String?
    var nickname: String?
    var content: String?
    var profileImageURL: String?
    
    init(id:Int, photo: String? , nickname: String?, content: String?, profileImageURL: String?) {
        self.id = id
        self.photo = photo
        self.nickname = nickname
        self.content = content
        self.profileImageURL = profileImageURL
    }
}

