//
//  Version1.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/6/17.
//
//

import Foundation

enum Command {
    case echo(body: String)
    case unrecognized(command: String)
    case usage(info: String)
    case help
    case info(arg: InfoArg)
    
    init?(input: String) {
        var commands = input.components(separatedBy: " ")
        
        guard commands.popFirst()?.lowercased() == Bot.current.name.lowercased() else { return nil }
        guard let command = commands.popFirst()?.lowercased() else {
            self = .usage(info: "commmand [args]\nUse \"jarvis help\" for a full list of commands.")
            return
        }
        
        switch command {
        case "echo": self = .echo(body: commands.joined(separator: " "))
        case "help": self = .help
        case "info":
            guard let first = commands.popFirst(), let arg = InfoArg(rawValue: first) else {
                self = .usage(info: "info [members/age/messages]")
                return
            }
            
            self = .info(arg: arg)
        default: self = .unrecognized(command: command)
        }
    }
}

enum InfoArg: String {
    case members
    case age
    case messages
}

class V1 {
    
    // Program should not be initialized
    private init() { }
    
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
