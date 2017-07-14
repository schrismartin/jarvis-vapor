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
        
        guard let command = Command(postback: postback) else {
            Debug.log("User did not invoke the \"jarvis\" keyword")
            return handlePassiveMessage(using: postback)
        }
        
        switch command {
        // case .echo(body: let body): return echo(body: body)
        // case .unrecognized(command: let command): return unrecognized(command: command)
        // case .usage(let info): return usage(info: info)
        // case .help: return help()
        // case .fuck: return fuck(user: postback.user)
        // case .cat: return cat(type: .cat)
        // case .kitten: return cat(type: .kitten)
        // case .harass(user: let user): return harass(user: user)
        // case .cease(user: let user): return cease(user: user)
        // case .info(let arg): return info(arg: arg)
            
        case .echo(var body):
            return handleEcho(&body)
            
        case .unrecognized(let command):
            return handleUnrecognizedCommand(command)
            
        case .usage(let info):
            return handleUsage(info)
            
        case .help:
            return handleHelp()
            
        case .test:
            return handleTest()
            
        case .fuck(let user):
            return handleFuckCommand(user)
            
        case .harass(user: let user):
            return handleHarassCommand(user)
            
        case .cease(user: let user):
            return handleCeaseCommand(user)
            
        case .inspire:
            return handleInspireCommand()
            
        case .info(let arg):
            return handleInfoCommand(arg: arg)
            
        case .cat:
            return handleCatCommand(type: .cat)
            
        case .kitten:
            return handleCatCommand(type: .kitten)
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

// MARK: - Message Handlers
extension V1 {
    
    fileprivate static func handleEcho(_ body: inout [MessageComponent]) -> Action {
        
        body.insert("Echo:", at: 0)
        let message = Message(payload: body)
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleUnrecognizedCommand(_ command: String) -> Action {
        
        let message = Message(components: "Unrecognized command: \(command)")
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleUsage(_ info: String) -> Action {
        
        let message = Message(components: "usage: jarvis \(info)")
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleHelp() -> Action {
        
        let message = Message.welcome
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleTest() -> Action {
        
        let user = User(id: "21964096", name: "Chris Martin")
        let message = Message(components: user, ": @ctually @ll @lligators @cclimate @ll @utum.", user)
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleFuckCommand(_ user: User) -> Action {
        
        let message = Message(components: "No, actually fuck you,", user)
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleHarassCommand(_ user: User) -> Action {
        
        return Action.register(user: user, category: .harass)
    }
    
    fileprivate static func handleCeaseCommand(_ user: User?) -> Action {
        
        return Action.cease(user: user)
    }
    
    fileprivate static func handleInspireCommand() -> Action {
        
        let message: Message
        
        if let inspirobot = InspiroBot() {
            message = Message(components: inspirobot.makeLink())
        } else {
            message = Message(components: "Roses are red, violets are blue. I've got no inspiration for you today. That's it, the end.")
        }
        
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleCatCommand(type: CatType) -> Action {
        var animal: ImageAttachment?
        var message: Message!
        
        switch type {
        case .cat: animal = Cat()
        case .kitten: animal = Kitten()
        }
        
        if let image = animal {
            message = Message(components: image.makeLink())
        } else {
            message = Message(components: "You don't currently have this enabled.")
        }
        
        return Action.messageSent(message: message)
    }
    
    fileprivate static func handleAgeCommand(_ info: GroupInfo) -> Action {
        
        let calendar = Calendar.current
        let now = Date()
        let timeAgo = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: info.createdAt, to: now)
        
        return Action.messageSent(message: Message(components: "This group was created \(timeAgo.year!) years, \(timeAgo.month!) months, \(timeAgo.day!) days, \(timeAgo.hour!) hours, \(timeAgo.minute!) minutes, and \(timeAgo.second!) seconds ago."))
    }
    
    fileprivate static func handleMembersCommand(_ info: GroupInfo) -> Action {
        
        let members = info.members.map { $0.name }.joined(separator: "\n- ")
        return Action.messageSent(message: Message(components: "This group has \(info.members.count) members:\n- " + members))
    }
    
    fileprivate static func handleMessageCountCommand(_ info: GroupInfo) -> Action {
        
        return Action.messageSent(message: Message(components: "This group has sent/received \(info.messageCount) messages."))
    }
    
    fileprivate static func handleInfoCommand(arg: Command.InfoArg) -> Action {
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
