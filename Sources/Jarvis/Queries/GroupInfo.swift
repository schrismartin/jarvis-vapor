//
//  GroupInfo.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/6/17.
//
//

import Foundation
import Vapor

enum GroupType: String {
    case `public`
    case `private`
}

struct GroupInfo {
    static let url = URL(string: URLs.groups.tokenized())!
    
    var id: String
    var name: String
    var type: GroupType
    var description: String
    var imageUrl: URL?
    var creatorUserId: String
    var createdAt: Date
    var updatedAt: Date
    var members: [User]
    
    var messageCount: Int
    
    init(from url: URL) throws {
        guard let response = JarvisServer.main.get(from: url), let json = response.json
            else { throw JarvisError.jsonConversion }
        
        do { try self.init(json: json) }
        catch { throw error }
    }
}

extension GroupInfo: JSONInitializable {
    
    init(json: JSON) throws {
        let json = json["response"]!
        
        guard
            let id = json["id"]?.string,
            let name = json["name"]?.string,
            let type = json["type"]?.string,
            let groupType = GroupType(rawValue: type),
            let description = json["description"]?.string,
            let creatorUserId = json["creator_user_id"]?.string,
            let createdEpoch = json["created_at"]?.string,
            let createdInterval = TimeInterval(createdEpoch),
            let updatedEpoch = json["updated_at"]?.string,
            let updatedInterval = TimeInterval(updatedEpoch),
            let members = json["members"]?.array as? [JSON],
            let messageCount = json["messages"]?["count"]?.int
            else { throw JarvisError.jsonConversion }
        
        self.id = id
        self.name = name
        self.type = groupType
        self.description = description
        
        self.creatorUserId = creatorUserId
        self.createdAt = Date(timeIntervalSince1970: createdInterval)
        self.updatedAt = Date(timeIntervalSince1970: updatedInterval)
        self.members = members.flatMap { try? User.init(json: $0) }
        self.messageCount = messageCount
    }
    
//    init(json: JSON) throws {
//        guard
//            let id = json["id"]?.string,
//            let name = json["name"]?.string,
//            let type = json["type"]?.string, let groupType = GroupType(rawValue: type),
//            let description = json["description"]?.string,
//            let imageString = json["image_url"]?.string, let imageUrl = URL(string: imageString),
//            let creatorUserId = json["creator_user_id"]?.string,
//            let createdEpoch = json["created_at"]?.string, let createdInterval = TimeInterval(createdEpoch),
//            let updatedEpoch = json["updated_at"]?.string, let updatedInterval = TimeInterval(updatedEpoch),
//            let members = json["members"]?.array as? [JSON],
//            let messageCount = json["messages"]?["count"]?.int
//        else {
//            throw JarvisError.jsonConversion
//        }
//        
//        self.id = id
//        self.name = name
//        self.type = groupType
//        self.description = description
//        self.imageUrl = imageUrl
//        self.creatorUserId = creatorUserId
//        self.createdAt = Date(timeIntervalSince1970: createdInterval)
//        self.updatedAt = Date(timeIntervalSince1970: updatedInterval)
//        self.members = members.flatMap { try? User.init(json: $0) }
//        self.messageCount = messageCount
//    }
    
}

//{
//    "id": "1234567890",
//    "name": "Family",
//    "type": "private",
//    "description": "Coolest Family Ever",
//    "image_url": "https://i.groupme.com/123456789",
//    "creator_user_id": "1234567890",
//    "created_at": 1302623328,
//    "updated_at": 1302623328,
//    "members": [
//    {
//    "user_id": "1234567890",
//    "nickname": "Jane",
//    "muted": false,
//    "image_url": "https://i.groupme.com/123456789"
//    }
//    ],
//    "share_url": "https://groupme.com/join_group/1234567890/SHARE_TOKEN",
//    "messages": {
//        "count": 100,
//        "last_message_id": "1234567890",
//        "last_message_created_at": 1302623328,
//        "preview": {
//            "nickname": "Jane",
//            "text": "Hello world",
//            "image_url": "https://i.groupme.com/123456789",
//            "attachments": [
//            {
//            "type": "image",
//            "url": "https://i.groupme.com/123456789"
//            },
//            {
//            "type": "image",
//            "url": "https://i.groupme.com/123456789"
//            },
//            {
//            "type": "location",
//            "lat": "40.738206",
//            "lng": "-73.993285",
//            "name": "GroupMe HQ"
//            },
//            {
//            "type": "split",
//            "token": "SPLIT_TOKEN"
//            },
//            {
//            "type": "emoji",
//            "placeholder": "☃",
//            "charmap": [
//            [
//            1,
//            42
//            ],
//            [
//            2,
//            34
//            ]
//            ]
//            }
//            ]
//        }
//    }
//}
