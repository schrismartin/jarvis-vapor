//
//  Inspirobot.swift
//  libc
//
//  Created by Chris Martin on 7/13/17.
//

import Foundation

class InspiroBot: ImageAttachment {
    
    var imageURL: URL
    
    required init?() {
        
        guard let result = JarvisServer.main.getString(from: .inspirobot),
            let urlString = try? String(bytes: result) else { return nil }
        
        imageURL = URL(string: urlString)!
    }
    
    func makeImage() -> GMImage {
        return GMImage(url: imageURL)
    }
    
    func makeLink() -> MessageComponent {
        return imageURL.absoluteString
    }
    
}
