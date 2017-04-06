//
//  Constants.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation

enum URLs: String {
    case root = "https://api.groupme.com/v3"
    case posts = "https://api.groupme.com/v3/bots/post"
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
