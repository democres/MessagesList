//
//  PostModel.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import Foundation

struct PostModel: Codable, Identifiable {
    var postId: Int
    var id: Int
    var name: String
    var email: String
    var body: String
}
