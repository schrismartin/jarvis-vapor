//
//  Bot.swift
//  Jarvis
//
//  Created by Chris Martin on 4/2/17.
//
//

import Foundation
import Vapor
import HTTP

class Bot {
    
    public static var current = Bot()
    public var id: String = Utils.getEnvVar(name: "BOT_ID") ?? "7b88634725687b654b8293117e"
    
    internal func performActions(from postback: Postback, version: APIVersion) throws -> Message {
        switch version {
        case .v1: return generateV1Content(from: postback)
        default:
            Utils.log("Received API Call targeting \(version.rawValue)")
            throw JarvisError.incorrectVersion
        }
    }
}

extension Bot {
    
    fileprivate func generateV1Content(from postback: Postback) -> Message {
        
        let description = String(describing: postback)
        Utils.log(description)
        
        return Message(content: "Echo: \(postback.message)")
    }
    
}


// MARK: - Utility Functions
extension Bot {
    
    public func send(message: Message) throws {
        // Create JSON Payload
        Utils.log("Message preparing to be created")
        let json = try message.makeJSON()
        let url = URL(from: .posts)
        Utils.log("Message successfully created")
        
        // Send
        Utils.log("Message attempting to post")
        
        JarvisServer.main.post(body: json, to: url)
    }
    
}
