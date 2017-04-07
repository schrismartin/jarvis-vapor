//
//  Postback.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation
import Vapor

public typealias GroupIdentifier = String
public typealias MessageIdentifier = String
public typealias UserIdentifier = String

public enum UserType: String {
    case user
    case bot
    case other
    
    public init(rawValue: String) {
        switch rawValue {
        case "user": self = .user
        case "bot": self = .bot
        default: self = .other
        }
    }
}

public struct User {
    public var id: UserIdentifier
    public var name: String
    public var avatarUrl: URL?
    public var type: UserType
    public var muted: Bool?
    
    init(id: UserIdentifier,
         name: String,
         avatarUrl: URL? = nil,
         type: UserType = .user,
         muted: Bool? = nil) {
        
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.type = type
        self.muted = muted
    }
}

extension User: JSONConvertible {
    
    public init(json: JSON) throws {
        // Check for required information
        guard
            let id = json["sender_id"]?.string ?? json["user_id"]?.string,
            let name = json["name"]?.string ?? json["nickname"]?.string
        else {
            throw JarvisError.jsonConversion
        }
        
        // Create optional/intermediary fields
        let type = UserType(rawValue: json["sender_type"]?.string ?? "user")
        let avatarUrl = URL(string: json["avatar_url"]?.string ?? "")
        let muted = json["muted"]?.bool
        
        // Create object
        self.init(id: id, name: name, avatarUrl: avatarUrl, type: type, muted: muted)
    }
    
    public func makeJSON() throws -> JSON {
        let urlStr = avatarUrl?.absoluteString
        
        return try JSON(node: [
            "sender_id": Node(id),
            "name": Node(name),
            "avatar_url": urlStr == nil ? .null : Node(urlStr!),
            "sender_type": Node(type.rawValue)
        ])
    }
}

public struct GMGroup {
    public var id: GroupIdentifier
    
    public init(from id: GroupIdentifier) {
        self.id = id
    }
}

public struct Postback {
    public var created: Date
    public var group: GMGroup
    public var id: MessageIdentifier
    public var user: User
    public var message: String
}

extension Postback: JSONInitializable {
    
    public init(json: JSON) throws {
        guard
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
        
        self.created = Date(timeIntervalSince1970: TimeInterval(createdAt))
        self.group = GMGroup(from: groupId)
        self.id = id
        self.message = text
        
        guard let url = URL(string: avatarUrl) else {
            throw JarvisError.urlCreation(urlSource: avatarUrl)
        }
        
        self.user = User(
            id: userId,
            name: name,
            avatarUrl: url,
            type: UserType(rawValue: senderType)
        )
    }
    
}

//{
//    "attachments": [],
//    "avatar_url": "http://i.groupme.com/123456789",
//    "created_at": 1302623328,
//    "group_id": "1234567890",
//    "id": "1234567890",
//    "name": "John",
//    "sender_id": "12345",
//    "sender_type": "user",
//    "source_guid": "GUID",
//    "system": false,
//    "text": "Hello world ☃☃",
//    "user_id": "1234567890"
//}
