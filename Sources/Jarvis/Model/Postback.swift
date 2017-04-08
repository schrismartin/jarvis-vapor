//
//  Postback.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation
import Vapor


public typealias MessageIdentifier = String



public struct Postback {
    public var attachments: [Attachment]
    public var created: Date
    public var group: Group
    public var id: MessageIdentifier
    public var user: User
    public var message: String
}

extension Postback: JSONInitializable {
    
    public init(json: JSON) throws {
        
        // Extract necessary components
        guard
            let attachments = json["attachments"]?.array as? [JSON],
            let avatarUrl = json["avatar_url"]?.string,
            let createdAt = json["created_at"]?.int,
            let groupId = json["group_id"]?.string,
            let id = json["id"]?.string,
            let name = json["name"]?.string,
            let senderType = json["sender_type"]?.string,
            let _ = json["sender_id"]?.string,
            let text = json["text"]?.string,
            let userId = json["user_id"]?.string
            else { throw JarvisError.jsonConversion }
        
        // Assign captured properties
        self.attachments = attachments.flatMap { try? Attachment(json: $0, message: text) }
        self.created = Date(timeIntervalSince1970: TimeInterval(createdAt))
        self.group = Group(from: groupId)
        self.id = id
        self.message = text
        
        // Create URL
        guard let url = URL(string: avatarUrl) else {
            throw JarvisError.urlCreation(urlSource: avatarUrl)
        }
        
        // Create the user
        self.user = User(
            id: userId,
            name: name,
            avatarUrl: url,
            type: UserType(rawValue: senderType)
        )
    }
    
}
