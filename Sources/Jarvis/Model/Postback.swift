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
    public var message: MessagePayload
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
        let newAttachments = attachments.flatMap { try? Attachment(json: $0, message: text) }
        self.attachments = newAttachments
        self.created = Date(timeIntervalSince1970: TimeInterval(createdAt))
        self.group = Group(from: groupId)
        self.id = id
        self.message = Postback.process(content: text, with: newAttachments)
        
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
    
    static func process(content: String, with attachments: [Attachment]) -> MessagePayload {
        var attachments = attachments
        
        // Iterate through each attachment – allows for multiple attachment handling.
        while var attachment = attachments.popLast() {
            var newPayload = [MessagePayload]()
            
            switch attachment.type {
            case .mentions: // Perform this action if mentions are involved
                
                // Split by mentions
                let payload: MessagePayload = content.components(separatedBy: "@")
                for case let component as String in payload {
                    
                    // Make sure there's a user in the attachment, 
                    // and that the message length does not exceed the user's name
                    guard let user = attachment.users?.first, component.count >= user.name.count else { continue }
                    let substring = component.substring(at: 0, length: user.name.count)
                    if substring == user.name {
                        attachment.users?.popFirst()
                        let other = component.substring(at: user.name.count, length: component.count - user.name.count)
                        var content: MessagePayload = other.components(separatedBy: " ")
                        content.insert(user, at: 0)
                        newPayload.append(content)
                    } else {
                        newPayload.append(component.components(separatedBy: " "))
                    }
                }
            }
            
            return newPayload.flatMap { $0.flatMap { return $0.description != "" ? $0 : nil } }
        }
        
        // if no attachments,
        return content.components(separatedBy: " ")
    }
    
}
