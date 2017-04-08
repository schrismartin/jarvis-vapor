//
//  Utilities.swift
//  Jarvis
//
//  Created by Chris Martin on 4/1/17.
//
//

import Foundation

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
    public static func getEnvVar(name: String) -> String {
        guard let rawValue = getenv(name) else {
            Debug.log("Environment Variable \"\(name)\" could not be initialized.")
            fatalError("Environment Variable \"\(name)\" could not be initialized.")
        }
        
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
    
}

extension Array {
    
    
    /// Remove the first element from an array
    ///
    /// - Returns: Value removed
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
