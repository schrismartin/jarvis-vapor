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
    case error(message: String)
    
    init?(input: String) {
        var commands = input.components(separatedBy: " ")
        guard commands.remove(at: 0).lowercased() == Bot.current.name.lowercased() else {
            return nil
        }
        
        guard commands.count > 0 else {
            self = .error(message: "usage: jarvis command [args]")
            return
        }
        
        let command = commands.remove(at: 0)
        switch command {
        case "echo":
            self = .echo(body: commands.joined(separator: " "))
        default:
            self = .unrecognized(command: command)
        }
    }
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
        case .error(message: let input):
            let message = Message(content: input)
            return Action.messageSent(message: message)
        }
    }
    
}
