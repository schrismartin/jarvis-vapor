//
//  Version1.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/6/17.
//
//

import Foundation

class V1 {
    
    // Program should not be initialized
    private init() { }
    
    
    /// Generate an action in order to be performed by the bot.
    ///
    /// - Parameter postback: The input `Postback` object returned when a user sends a message.
    /// - Returns: The action to be perfocmed by the bot when finished.
    internal static func generateAction(using postback: Postback) -> Action {
        
        guard let command = Command(input: postback.message) else {
            Debug.log("User did not invoke the \"jarvis\" keyword")
            return Action.none
        }
        
        switch command {
        case .echo(body: let body):
            let message = Message(content: "Echo: \(body)")
            return Action.messageSent(message: message)
            
        case .unrecognized(command: let command):
            let message = Message(content: "Unrecognized command: \(command)")
            return Action.messageSent(message: message)
            
        case .usage(let info):
            let message = Message(content: "usage: jarvis \(info)")
            return Action.messageSent(message: message)
            
        case .help:
            let message = Message.welcome
            return Action.messageSent(message: message)
            
        case .test:
            let user = User(id: "21964096", name: "Chris Martin")
            let message = Message(content: user, ": @ctually @ll @lligators @cclimate @ll @utum. ", user)
            return Action.messageSent(message: message)
            
        case .fuck:
            let user = postback.user
            let message = Message(content: "No, actually fuck you, ", user, ".")
            return Action.messageSent(message: message)
            
        case .info(let arg):
            do {
                let info = try GroupInfo(from: GroupInfo.url)
                switch arg {
                case .age:
                    return Action.messageSent(message: Message(content: "This group was created at \(info.createdAt)."))
                case .members:
                    let members = info.members.map { $0.name }.joined(separator: "\n- ")
                    return Action.messageSent(message: Message(content: "This group has \(info.members.count) members:\n- " + members))
                case .messages:
                    return Action.messageSent(message: Message(content: "This group has sent/received \(info.messageCount) messages."))
                }
            } catch {
                let message = Message.failed
                return Action.messageSent(message: message)
            }
        }
    }
    
}
