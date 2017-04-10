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
            
        case .cease:
            return Action.cease
            
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
        let insults = [
            "No.",
            "Stop talking.",
            "You're killing me.",
            "Stahp.",
            "Nobody cares",
            "Fuck off.",
            "Leave please.",
            "Kill yourself.",
            "If you don't stop talking, I'm going to leave.",
            "Wow. Brilliant. Such a great contribution.",
            "You're trying too hard.",
            "Stop while you're behind.",
            "Do you ever stop talking?",
            "I think you need some mental help.",
            "Dude...",
            "Such dumb, very cringe. Wow.",
            "2/10, would not read again.",
            "Is your ass jealous of the amount of shit that just came out of your mouth?",
            "If I wanted to kill myself I'd climb your ego and jump to your IQ.",
            "I'd like to see things from your point of view but I can't seem to get my head that far up my ass.",
            "It's better to let someone think you are an Idiot than to open your mouth and prove it.",
            "Hell is wallpapered with all your deleted selfies.",
            "It looks like your face caught on fire and someone tried to put it out with a hammer.",
            "If ignorance is bliss, you must be the happiest person on earth.",
            "I wasn't born with enough middle fingers to let you know how I feel about you.",
            "What language are you speaking? Cause it sounds like bullshit.",
            "You're the reason the gene pool needs a lifeguard.",
            "You are proof that evolution CAN go in reverse.",
            "I don't think you are stupid. You just have bad luck when thinking.",
            "If I had a face like yours, I'd sue my parents.",
            "So, a thought crossed your mind? Must have been a long and lonely journey.",
            "I don't know what makes you so stupid, but it really works.",
            "Calling you an idiot would be an insult to all stupid people.",
            "Aha, I see the Fuck-Up Fairy has visited us again!",
            "I would love to insult you... but that would be beyond the level of your intelligence.",
            "Keep talking, someday you'll say something intelligent!"
        ]
        
        let index = randInt(upperBound: insults.count - 1)
        return insults[index]
    }
    
}
