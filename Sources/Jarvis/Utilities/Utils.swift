//
//  Utilities.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation
import Vapor

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


public struct Utils {
    
    private init() {
        fatalError("Utils class should never be initialized")
    }
    
    
    /// Retrieve an environment variable.
    ///
    /// - Parameter name: Variable name
    /// - Returns: Environment value if variable exists, nil otherwise.
    public static func getEnvVar(name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)!
    }
}

public struct Debug {
    
    private init() {
        fatalError("Debug struct should never be initialized")
    }
    
    
    /// Write a message to the screen and flush the buffer. Useful when logging things through Heroku
    ///
    /// - Parameter string: Message to be displayed
    public static func log(_ string: String) {
        fputs("\(string)\n", stdout)
        fflush(stdout)
    }
    
    public static func log(json: JSON) {
        if let json = try? json.serialize(prettyPrint: true) {
            let data = Data(bytes: json)
            let string = String(data: data, encoding: .utf8)
            Debug.log(string!)
        } else {
            Debug.log("JSON could not be deserialized")
        }
    }
    
}

extension Array {
    
    
    /// Remove the first element from an array
    ///
    /// - Returns: Value removed
    @discardableResult
    mutating func popFirst() -> Element? {
        return count > 0 ? remove(at: 0) : nil
    }
    
}

extension String {
    
    /// Returns the substring starting at an index with a length offset
    ///
    /// - Parameters:
    ///   - start: Start index 
    ///   - length: Number of characters to be captured
    /// - Returns: The resulting substring of the operation.
    func substring(at start: Int, length: Int) -> String {
        let low = index(startIndex, offsetBy: start)
        let high = index(startIndex, offsetBy: start + length)
        let range = Range(uncheckedBounds: (low, high))
        return substring(with: range)
    }
}

public func randInt(upperBound: Int) -> Int {
    #if os(Linux)
        return Int(random() % (upperBound + 1))
    #else
        return Int(arc4random_uniform(UInt32(upperBound)))
    #endif
}
