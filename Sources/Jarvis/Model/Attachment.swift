//
//  Attachment.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/8/17.
//
//

import Foundation
import Vapor

enum AttachmentType: String {
    case mentions
    case image
}

public struct Attachment {
    var type: AttachmentType
    var users: [User]?
    var associatedContent: String?
    var imageUrl: URL?
    
    init(type: AttachmentType, users: [User]? = nil, associatedContent: String? = nil, imageURL: URL? = nil) {
        self.type = type
        self.users = users
        self.associatedContent = associatedContent
        self.imageUrl = imageURL
    }
}

extension Attachment {
    public init(json: JSON, message: String?) throws {
        guard
            let str = json["type"]?.string,
            let type = AttachmentType(rawValue: str) else {
                throw JarvisError.jsonConversion
        }
        
        self.type = type
        
        switch self.type {
        case .mentions:
            guard let message = message else { throw JarvisError.invalidArguments }
            users = try? Attachment.parseMentions(using: json, from: message)
        case .image:
            imageUrl = try? Attachment.parseImage(using: json)
        }
    }
    
    static func parseImage(using json: JSON) throws -> URL {
        guard
            let string = json["url"]?.string,
            let url = URL(string: string)
            else { throw JarvisError.jsonConversion }
        
        return url
    }
    
    static func parseMentions(using json: JSON, from message: String) throws -> [User] {
        // Seed the users array
        var users = [User]()
        
        // Extract the loci variable
        guard let loci = json["loci"]?.array as? [JSON],
            let userIds = json["user_ids"]?.array as? [JSON] else { throw JarvisError.jsonConversion }
        
        // Iterate through the loci array
        for (index, element) in loci.enumerated() {
            guard let rawRange = element.array as? [JSON] else { continue }
            
            // Grab username substring while stripping the @ symbol
            let username = message.substring(
                at: rawRange[0].int! + 1,
                length: rawRange[1].int! - 1
            )
            
            // Extract the id and create the user
            let id = userIds[index].string!
            let user = User(id: id, name: username)
            
            // Add to the user list
            users.append(user)
        }
        
        return users
    }
}

extension Attachment: JSONRepresentable {

    fileprivate func calculateMentionIndices(for content: String) -> [[Int]]? {
        guard var mentions = users, !mentions.isEmpty, type == .mentions else { return nil }
        var indices = [[Int]]()
        var content = content
        
        for (index, character) in content.characters.enumerated() where character == "@" {
            guard let user = mentions.first else { continue }
            if content.substring(at: index, length: user.description.count) == user.description {
                mentions.popFirst()
                indices.append([ index, user.description.count ])
            }
        }
        
        return indices
    }
    
    public func makeJSON() throws -> JSON {
        switch type {
        case .mentions:
            guard
                let content = associatedContent,
                let ids = calculateMentionIndices(for: content),
                let users = self.users else {
                throw JarvisError.jsonConversion
            }
            
            let idNode = ids.map { Node($0.map { Node($0) }) }
            let userIdNode = users.map { Node($0.id) }
            
            return JSON([
                "loci": Node(idNode),
                "type": Node(type.rawValue),
                "user_ids": Node(userIdNode)
            ])
            
        case .image:
            guard let url = imageUrl else { throw JarvisError.jsonConversion }
            
            return JSON([
                "type": Node(type.rawValue),
                "url": Node(url.absoluteString)
            ])
        }
        
    }
}
