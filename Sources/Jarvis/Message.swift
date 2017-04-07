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

extension Message {
    public static var usage: Message {
        return Message(content: "usage: jarvis commmand [args]\nUse \"jarvis help\" for a full list of commands.")
    }
    
    public static var failed: Message {
        return Message(content: "The command you just performed caused an error. Try again layer.")
    }
    
    public static var welcome: Message {
        return Message(content: "Welcome to Jarvis! You can currently use the following commands by invoking \"jarvis command [args]\"\n\n" +
            "echo: Echo the rest of the message to the screen\n" +
            "help: List of commands you can use with Jarvis")
    }
}
