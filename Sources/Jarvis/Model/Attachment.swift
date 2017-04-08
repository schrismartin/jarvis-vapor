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
}

public struct Attachment {
    var type: AttachmentType
    var users: [User]?
}

extension Attachment {
    public init(json: JSON, message: String) throws {
        guard
            let str = json["type"]?.string,
            let type = AttachmentType(rawValue: str) else {
                throw JarvisError.jsonConversion
        }
        
        self.type = type
        
        switch self.type {
        case .mentions:
            users = try? Attachment.parseMentions(using: json, from: message)
        }
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
