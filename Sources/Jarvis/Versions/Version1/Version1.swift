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
        case .echo(body: var body):
            body.insert("Echo:", at: 0)
            let message = Message(payload: body)
            return Action.messageSent(message: message)
            
        case .unrecognized(command: let command):
            let message = Message(components: "Unrecognized command: \(command)")
            return Action.messageSent(message: message)
            
        case .usage(let info):
            let message = Message(components: "usage: jarvis \(info)")
            return Action.messageSent(message: message)
            
        case .help:
            let message = Message.welcome
            return Action.messageSent(message: message)
            
        case .test:
            let user = User(id: "21964096", name: "Chris Martin")
            let message = Message(components: user, ": @ctually @ll @lligators @cclimate @ll @utum.", user)
            return Action.messageSent(message: message)
            
        case .fuck:
            let user = postback.user
            let message = Message(components: "No, actually fuck you,", user)
            return Action.messageSent(message: message)
            
        case .harass(user: let user):
            return Action.register(user: user, category: .harass)
            
        case .cease(user: let user):
            return Action.cease(user: user)
            
        case .info(let arg):
            do {
                let info = try GroupInfo(from: GroupInfo.url)
                switch arg {
                case .age:
                    return Action.messageSent(message: Message(components: "This group was created at \(info.createdAt)."))
                case .members:
                    let members = info.members.map { $0.name }.joined(separator: "\n- ")
                    return Action.messageSent(message: Message(components: "This group has \(info.members.count) members:\n- " + members))
                case .messages:
                    return Action.messageSent(message: Message(components: "This group has sent/received \(info.messageCount) messages."))
                }
            } catch {
                let message = Message.failed
                return Action.messageSent(message: message)
            }
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
