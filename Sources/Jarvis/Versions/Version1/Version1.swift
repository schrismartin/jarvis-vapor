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
        
        print(postback.message)
        
        guard let command = Command(input: postback.message) else {
            Debug.log("User did not invoke the \"jarvis\" keyword")
            return handlePassiveMessage(using: postback)
        }
        
        switch command {
        case .echo(body: let body): return echo(body: body)
        case .unrecognized(command: let command): return unrecognized(command: command)
        case .usage(let info): return usage(info: info)
        case .help: return help()
        case .fuck: return fuck(user: postback.user)
        case .cat: return cat(type: .cat)
        case .kitten: return cat(type: .kitten)
        case .harass(user: let user): return harass(user: user)
        case .cease(user: let user): return cease(user: user)
        case .info(let arg): return info(arg: arg)
        }
    }
    
    fileprivate static func handlePassiveMessage(using postback: Postback) -> Action {
        let user = postback.user
        let bot = BotService.current
        
        if bot.harassed.contains(user) {
            let insult = generateInsult()
            let message = Message(components: insult)
            return Action.messageSent(message: message)
        }
        
        return Action.none
    }
    
    fileprivate static func generateInsult() -> String {
        let insults = Insults.insults
        let index = randInt(upperBound: insults.count - 1)
        return insults[index]
    }
    
}
