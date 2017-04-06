import Foundation
import Vapor
import HTTP
import Jarvis

let server = JarvisServer.main.server

server.get { req in
    return try server.view.make("welcome", [
    	"message": server.localization[req.lang, "welcome", "title"]
    ])
}

server.post("api", ":version") { (request) -> ResponseRepresentable in
    guard
        let versionString = request.parameters["version"]?.string,
        let version = APIVersion(rawValue: versionString) else {
            throw Abort.badRequest
    }
    
    return try JarvisServer.main.handle(request: request, version: version)
}

server.resource("posts", PostController())

server.run()
