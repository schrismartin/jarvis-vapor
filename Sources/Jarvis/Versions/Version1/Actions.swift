//
//  Actions.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/23/17.
//
//

import Foundation

extension V1 {
    
    /// Echo the message back to the user
    ///
    /// - Parameter body: Message components that the user sent
    /// - Returns: Message Sent Action
    static func echo(body: MessagePayload) -> Action {
        let message = Message(payload: body)
        return Action.messageSent(message: message)
    }
    
    /// Send 
    ///
    /// - Parameter command: <#command description#>
    /// - Returns: <#return value description#>
    static func unrecognized(command: String) -> Action {
        let message = Message(components: "Unrecognized command:", command)
        return Action.messageSent(message: message)
    }
    
    static func usage(info: String) -> Action {
        let message = Message(components: "usage: jarvis \(info)")
        return Action.messageSent(message: message)
    }
    
    static func help() -> Action {
        let message = Message.welcome
        return Action.messageSent(message: message)
    }
    
    static func fuck(user: User) -> Action {
        let message = Message(components: "No, actually fuck you,", user)
        return Action.messageSent(message: message)
    }
    
    static func cat(type: CatType) -> Action {
        var animal: ImageAttachment?
        var message: Message!
        
        switch type {
        case .cat: animal = Cat()
        case .kitten: animal = Kitten()
        }
        
        if let image = animal {
            message = Message(components: image.makeImage())
        } else {
            message = Message(components: "You don't currently have this enabled.")
        }
        
        return Action.messageSent(message: message)
    }
    
    static func harass(user: User) -> Action {
        return Action.register(user: user, category: .harass)
    }
    
    static func cease(user: User?) -> Action {
        return Action.cease(user: user)
    }
    
    static func info(arg: Command.InfoArg) -> Action {
        guard let info = GroupInfo() else {
            let message = Message.failed
            return Action.messageSent(message: message)
        }
        
        switch arg {
        case .age:
            return Action.messageSent(message: Message(components: "This group was created at \(info.createdAt)."))
        case .members:
            let members = info.members.map { $0.name }.joined(separator: "\n- ")
            return Action.messageSent(message: Message(components: "This group has \(info.members.count) members:\n- " + members))
        case .messages:
            return Action.messageSent(message: Message(components: "This group has sent/received \(info.messageCount) messages."))
        }
    }
}
