//
//  Server.swift
//  Jarvis
//
//  Created by Chris Martin on 4/2/17.
//
//

import Foundation
import Vapor
import HTTP

public class JarvisServer {
    
    public static var main = JarvisServer()
    
    public var server: Droplet = {
        var server = Droplet()
        
        // Input any further initial server configuration here
        return server
    }()
    
    public func handle(request: Request, version: APIVersion) throws -> Response {
        // Debug information
        if let bytes = request.body.bytes {
            let data = Data(bytes: bytes)
            Debug.log(String(data: data, encoding: .utf8)!)
        }
        
        guard let json = request.json, let postback = try? Postback(json: json) else {
            Debug.log("Unable to convert received payload to Postback")
            throw Abort.badRequest
        }
        
        dump(postback)
        
        do {
            switch postback.user.type {
            case .user: try handleUserPostback(using: postback, version: version)
            case .bot: try handleBotPostback(using: postback, version: version)
            default: break
            }
            
            return Response(status: .ok)
        } catch let error as JarvisError {
            Debug.log("Jarvis-related error received when handling postback. Error: \(error), Postback: \(postback)")
            return Response(status: .internalServerError)
        }
        
    }
    
    func handleUserPostback(using postback: Postback, version: APIVersion) throws {
        Debug.log("User postback detected, continuing")
        let action = try Bot.current.generateAction(using: postback, version: version)
        
        switch action {
        case .messageSent(message: let message):
            let url = URL(from: .posts)
            post(body: try message.makeJSON(), to: url)
        default:
            break
        }
    }
    
    func handleBotPostback(using postback: Postback, version: APIVersion) throws {
        Debug.log("Bot postback detected, payload discarded")
    }
}

extension JarvisServer {

    @discardableResult
    func post(body: BodyRepresentable, headers: [HeaderKey: String] = ["Content-Type": "application/json"], to url: URL) -> Response? {
        let client = server.client
        return try? client.post(url.absoluteString, headers: headers, body: body)
    }
    
    func get(from url: URL) -> Response? {
        let client = server.client
        return try? client.get(url.absoluteString)
    }
    
}
