//
//  Commands.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/8/17.
//
//

import Foundation

/// Command enum allows for stronger command parsing. 
/// Each command available to the user must be
/// represented here.
///
/// - echo: The rest of the message is to be mirrored back to the user
/// - unrecognized: The command was unrecognized
/// - usage: The query was improperly constructed
/// - help: Return a help message back to the user
/// - info: User requested information based on the channel
enum Command {
    case echo(body: String)
    case unrecognized(command: String)
    case usage(info: String)
    case help
    case info(arg: InfoArg)
    
    enum InfoArg: String {
        case members
        case age
        case messages
    }
    
    
    init?(input: String) {
        var commands = input.components(separatedBy: " ")
        
        guard commands.popFirst()?.lowercased() == BotService.current.name.lowercased() else { return nil }
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



