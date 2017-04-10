//
//  User.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/8/17.
//
//

import Foundation
import Vapor

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

extension User: Hashable {
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.hashValue == rhs.hashValue
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

// Add conformance to the MessageComponent protocol
extension User: MessageComponent {
    public var textualRepresentation: String {
        return "@\(name)"
    }
    
    public var description: String {
        return textualRepresentation
    }
}
