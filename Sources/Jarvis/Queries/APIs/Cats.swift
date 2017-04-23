//
//  Kittens.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/13/17.
//
//

import Foundation
import Vapor
import HTTP

class Cat {
    
    var imageURL: URL
    
    init?() {
        guard let mashapeKey = Utils.getEnvVar(name: "MASHAPE") else { return nil }
        
        let headers: [HeaderKey: String] = [
            "X-Mashape-Key": mashapeKey,
            "Accept": "application/json"
        ]
        
        guard let result = JarvisServer.main.get(from: .cat, headers: headers),
            let source = result["source"]?.string,
            let url = URL(string: source) else { return nil }
        
        imageURL = url
    }
    
    func makeImage() -> GMImage {
        return GMImage(url: imageURL)
    }
    
}

class Kitten {
    
    var imageURL: URL
    
    init?() {
        guard let mashapeKey = Utils.getEnvVar(name: "MASHAPE") else { return nil }
        
        let headers: [HeaderKey: String] = [
            "X-Mashape-Key": mashapeKey,
            "Accept": "application/json"
        ]
        
        guard let result = JarvisServer.main.get(from: .kitten, headers: headers),
            let source = result["source"]?.string,
            let url = URL(string: source) else { return nil }
        
        imageURL = url
    }
    
    func makeImage() -> GMImage {
        return GMImage(url: imageURL)
    }
    
}
