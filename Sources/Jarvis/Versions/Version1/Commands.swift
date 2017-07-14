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
    
    case echo(body: MessagePayload)
    case unrecognized(command: String)
    case usage(info: String)
    case help
    case cat
    case kitten
    case test
    case fuck(user: User)
    case harass(user: User)
    case info(arg: InfoArg)
    case cease(user: User?)
    case inspire
    
    enum InfoArg: String {
        
        case members
        case age
        case messages
        
        init?(component: MessageComponent) {
            
            let description = String(describing: component)
            self.init(rawValue: description)
        }
    }
    
    init?(postback: Postback) {
        var commands = postback.message
        
        guard (commands.popFirst() as? String)?.lowercased() == BotService.current.name.lowercased() else { return nil }
        guard let string = commands.popFirst() as? String else {
            self = .usage(info: "commmand [args]\nUse \"jarvis help\" for a full list of commands.")
            return
        }
        
        let command = string.lowercased()
        switch command {

        case "cat": 
            self = .cat

        case "kitten": 
            self = .kitten
            
        case "echo":
            self = .echo(body: commands)
            
        case "help":
            self = .help
            
        case "test":
            self = .test
            
        case "fuck":
            self = .fuck(user: postback.user)
            
        case "cease":
            if let user = commands.popFirst() as? User {
                self = .cease(user: user)
            } else {
                self = .cease(user: nil)
            }
            
        case "harass":
            guard let user = commands.popFirst() as? User else {
                self = .usage(info: "harass [@user]")
                return
            }
            
            self = .harass(user: user)

        case "info":
            guard let first = commands.popFirst(), let arg = InfoArg(component: first) else {
                self = .usage(info: "info [members/age/messages]")
                return
            }
            
            self = .info(arg: arg)
            
        case "inspire":
            self = .inspire
            
        default: self = .unrecognized(command: command)
        }
    }
}



