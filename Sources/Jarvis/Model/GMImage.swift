//
//  GMImage.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/16/17.
//
//

import Foundation

struct GMImage: MessageComponent {
    var url: URL
    
    var description: String {
        return url.absoluteString
    }
    
    var attachment: Attachment {
        return Attachment(type: .image, imageURL: url)
    }
}
