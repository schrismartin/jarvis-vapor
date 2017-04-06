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
    
    
    
    /**
     Perform relevant actions associated with generating a response to the user.
     - parameter postback: Postback payload returned by GroupMe
     - parameter version: API Version used in the call.
     - returns: `Message` containing feedback, if feedback is required, `nil` otherwise.
     */
    internal func generateAction(using postback: Postback, version: APIVersion) throws -> Action {
        
        switch version {
        case .v1: return V1.generateAction(using: postback)
        default:
            Debug.log("Received API Call targeting \(version.rawValue)")
            throw JarvisError.incorrectVersion
        }
    }
}


// MARK: - Utility Functions
extension Bot {
    
    public func send(message: Message) throws {
        // Create JSON Payload
        Debug.log("Message preparing to be created")
        let json = try message.makeJSON()
        let url = URL(from: .posts)
        Debug.log("Message successfully created")
        
        // Send
        Debug.log("Message attempting to post")
        
        JarvisServer.main.post(body: json, to: url)
    }
    
}
