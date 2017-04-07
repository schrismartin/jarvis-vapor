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
    
    public static func getEnvVar(name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
    }
}

public struct Debug {
    
    private init() {
        fatalError("Debug struct should never be initialized")
    }
    
    public static func log(_ string: String) {
        fputs("\(string)\n", stdout)
        fflush(stdout)
    }
    
}

extension Array {
    
    mutating func popFirst() -> Element? {
        return count > 0 ? remove(at: 0) : nil
    }
    
}

extension String {
    func substring(at start: Int, length: Int) -> String {
        let low = index(startIndex, offsetBy: start)
        let high = index(startIndex, offsetBy: start + length)
        let range = Range(uncheckedBounds: (low, high))
        return substring(with: range)
    }
}
