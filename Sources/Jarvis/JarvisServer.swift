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
    
    public func handle(request: Request, version: APIVersion = .v1) throws -> Response {
        guard let json = request.json, let postback = try? Postback(json: json) else {
            Utils.log("Unable to convert received payload to Postback")
            throw Abort.badRequest
        }
        
        let message = try Bot.current.performActions(from: postback, version: version)
        let url = URL(from: .posts)
        post(body: try message.makeJSON(), to: url)
        
        return Response(status: .ok)
    }
    
    @discardableResult
    func post(body: BodyRepresentable, headers: [HeaderKey: String] = ["Content-Type": "application/json"], to url: URL) -> Response? {
        let client = server.client
        return try? client.post(url.absoluteString, headers: headers, body: body)
    }
}
