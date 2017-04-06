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

public class Utils {
    
    public static func log(_ string: String) {
        fputs("\(string)\n", stdout)
        fflush(stdout)
    }
    
    public static func getEnvVar(name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
    }
}
