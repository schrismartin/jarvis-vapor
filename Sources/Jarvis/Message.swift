//
//  Message.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation
import Vapor

struct Message {
    var content: String
}

extension Message: JSONConvertible {
    func makeJSON() throws -> JSON {
        return JSON([
            "text": Node(content),
            "bot_id": Node(Bot.current.id)
        ])
    }
    
    init(json: JSON) throws {
        guard let text = json["text"]?.string else {
            throw JarvisError.jsonConversion
        }
        
        self.content = text
    }
}

extension Message: Hashable {
    var hashValue: Int {
        return content.hashValue
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
