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

class BotService {
    
    public static var current = BotService()
    public var id: String = Utils.getEnvVar(name: "BOT_ID")
    public var name: String = Utils.getEnvVar(name: "BOT_NAME")
    public var groupId: String = Utils.getEnvVar(name: "GROUP_ID")
    public var accessToken: String = Utils.getEnvVar(name: "ACCESS_TOKEN")
    
    private init () {
        // Should only be called by the singleton instance (Bot.current)
    }
    
    /// Perform relevant actions associated with generating a response to the user.
    ///
    /// - Parameters:
    ///   - postback: Postback payload returned by GroupMe
    ///   - version: Requested API version used to parse commands.
    /// - Returns: Server action to be interpreted and performed.
    /// - Throws: If an unavailable version is referenced, an error will be thrown.
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
extension BotService {
    
    
    /// Send a message to the bot's approved group
    ///
    /// - Parameter message: Message payload to be sent
    /// - Throws: If a JSON representation of the message 
    ///           cannot be created, an error is thrown.
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
