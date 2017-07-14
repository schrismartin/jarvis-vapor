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

enum CatType {
    case cat
    case kitten
}

protocol ImageAttachment {
    var imageURL: URL { get }
    
    init?()
    
    func makeImage() -> GMImage
    func makeLink() -> MessageComponent
}

class Cat: ImageAttachment {
    
    var imageURL: URL
    
    required init?() {
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
    
    func makeLink() -> MessageComponent {
        return imageURL.absoluteString
    }
    
}

class Kitten: ImageAttachment {
    
    var imageURL: URL
    
    required init?() {
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
    
    func makeLink() -> MessageComponent {
        return imageURL.absoluteString
    }
    
}
