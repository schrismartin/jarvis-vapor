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
    
    internal static func generateAction(using postback: Postback) -> Action {
        
        let description = String(describing: postback)
        Debug.log(description)
        
        let message = Message(content: "Echo: \(postback.message)")
        return Action.messageSent(message: message)
    }
    
}
