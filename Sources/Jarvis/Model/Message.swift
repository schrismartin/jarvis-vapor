//
//  Message.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation
import Vapor


/// Message object to be sent to GroupMe
struct Message {
    
    /// Content string for the message
    var content: String
    
    /// List of users to be mentioned in this
    var mentions = [User]()
    
    /// Create a Message object using a sequence of components, including
    /// strings and User objects
    ///
    /// - Parameter content: Strings or User objects used to construct a message
    init(components: MessageComponent...) {
        self.init(payload: components)
    }
    
    init(payload: MessagePayload) {
        self.content = payload
            .map { $0.textualRepresentation }
            .joined(separator: " ")
        
        for case let user as User in payload {
            mentions.append(user)
        }
    }
    
    fileprivate func generateAttachment() -> Attachment? {
        guard !mentions.isEmpty else { return nil }
        
        return Attachment(type: .mentions, users: mentions, associatedContent: content)
    }
}

// Allow messages to be represented by a simple String
extension Message: ExpressibleByStringLiteral {
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(components: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(components: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(components: "\(value)")
    }
    
}

extension Message: JSONConvertible {
    
    init(json: JSON) throws {
        guard let text = json["text"]?.string else {
            throw JarvisError.jsonConversion
        }
        
        self.content = text
    }
    
    func makeJSON() throws -> JSON {
        let attachment = generateAttachment()
        let field: Node = attachment == nil ? .null : Node([try attachment!.makeJSON().node])
        
        return JSON([
            "text": Node(content),
            "bot_id": Node(BotService.current.id),
            "attachments": field
        ])
    }
}

extension Message: Hashable {
    var hashValue: Int {
        return content.hashValue
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Message {
    public static var usage: Message {
        return Message(components: "usage: jarvis commmand [args]\nUse \"jarvis help\" for a full list of commands.")
    }
    
    public static var failed: Message {
        return Message(components: "The command you just performed caused an error. Try again layer.")
    }
    
    public static var welcome: Message {
        return Message(components: "Welcome to Jarvis! You can currently use the following commands by invoking \"jarvis command [args]\"\n\n" +
            "echo: Echo the rest of the message to the screen\n" +
            "help: List of commands you can use with Jarvis")
    }
}

/// Marker protocol to allow the concatenation of Strings and
/// users to create a message with a mention.
public protocol MessageComponent: CustomStringConvertible {
    var textualRepresentation: String { get }
}


/// Collection of message components
public typealias MessagePayload = [MessageComponent]

// Make Strings confirom to the MessageComponent protocol
extension String: MessageComponent {
    public var textualRepresentation: String {
        return self
    }
}
