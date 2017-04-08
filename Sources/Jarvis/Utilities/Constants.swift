//
//  Constants.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation

enum URLs {
    case root
    case posts
    case groups
    
    var rawValue: String {
        switch self {
        case .root: return "https://api.groupme.com/v3"
        case .posts: return "https://api.groupme.com/v3/bots/post"
        case .groups: return "https://api.groupme.com/v3/groups/\(BotService.current.groupId)"
        }
    }
    
    func tokenized() -> String {
        return "\(self.rawValue)?token=\(BotService.current.accessToken)"
    }
}

extension URL {
    
    /**
     * Create a URL from the safety-checked enum.
     */
    init(from url: URLs) {
        self.init(string: url.rawValue)!
    }
}

enum JarvisError: Error {
    case jsonConversion
    case urlCreation(urlSource: String)
    case incorrectVersion
}

public enum APIVersion: String {
    case v1
    case v2
    case v3
    case v4
    case v5
}

enum Action {
    case messageSent(message: Message)
    case messageStored
    case none
}
