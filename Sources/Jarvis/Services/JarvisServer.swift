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

/// Singleton Instance responsible for performing direct communicaiton to endpoints
public class JarvisServer {
    
    /// Singleton instance
    public static var main = JarvisServer()
    
    /// Main server instance
    public var server: Droplet = {
        var server = Droplet()
        
        // Input any further initial server configuration here
        _ = BotService.current // Assure an initialization on startup
        
        return server
    }()
    
    
    /// Front-line handler for server requests. Converts received postback information
    /// into Postback object, allowing for more robust handling of information. Delegates
    /// the handling of information based on sender type.
    ///
    /// - Parameters:
    ///   - request: Vapor Request object containing information
    ///   - version: Requested API version used to parse commands.
    /// - Returns: Status code response to GroupMe servers
    /// - Throws: Non-developer thrown errors, including Abort.badRequest and similar.
    public func handle(request: Request, version: APIVersion) throws -> Response {
        
        // Debug received information
        if let bytes = request.body.bytes {
            let data = Data(bytes: bytes)
            Debug.log(String(data: data, encoding: .utf8)!)
        }
        
        // JSON Conversion
        guard let json = request.json, let postback = try? Postback(json: json) else {
            Debug.log("Unable to convert received payload to Postback")
            throw Abort.badRequest
        }
        
        do {
            // Proceidure Delegation
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
    
    
    /// Handle messages sent by other GroupMe users.
    ///
    /// - Parameters:
    ///   - postback: Paramerized object containing postback information provided by GroupMe
    ///   - version: Requested API version used to parse commands.
    /// - Throws: If an unavailable version is referenced, an error will be thrown.
    func handleUserPostback(using postback: Postback, version: APIVersion) throws {
        Debug.log("User postback detected, continuing")
        let action = try BotService.current.generateAction(using: postback, version: version)
        
        switch action {
        case .messageSent(message: let message):
            let url = URL(from: .posts)
            Debug.log("Sending a message: \(message.content)")
            post(body: try message.makeJSON(), to: url)
            
        default:
            break
        }
    }
    
    
    /// Handle messages sent by bots.
    ///
    /// - Parameters:
    ///   - postback: Parameterized object containing postback information provided by GroupMe
    ///   - version: Requested API version used to parse commands.
    /// - Throws: If an unavailable version is referenced, an error will be thrown.
    func handleBotPostback(using postback: Postback, version: APIVersion) throws {
        Debug.log("Bot postback detected, payload discarded")
    }
}

extension JarvisServer {

    
    /// Create a POST request and send. This is a layer on top of Vapor's client POST system.
    ///
    /// - Parameters:
    ///   - body: Bytes containing POST data to be sent, generally in JSON format.
    ///   - headers: POST headers, defaulting to `Content-Type: application/json`.
    ///   - url: Destination URL of the endpoint.
    /// - Returns: HTTP Response provided by the endpoint.
    @discardableResult
    func post(body: BodyRepresentable = Body(), headers: [HeaderKey: String] = ["Content-Type": "application/json"], to url: URL) -> Response? {
        let client = server.client
        return try? client.post(url.absoluteString, headers: headers, body: body)
    }
    
    
    /// Create a GET request and send. This is a layer on top of Vapor's client GET system.
    ///
    /// - Parameter url: Destination URL of the endpoint.
    /// - Returns: HTTP Response provided by the endpoint.
    func get(from url: URL) -> Response? {
        let client = server.client
        return try? client.get(url.absoluteString)
    }
    
}
