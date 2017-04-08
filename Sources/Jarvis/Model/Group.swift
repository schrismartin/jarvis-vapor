//
//  Group.swift
//  jarvis-vapor
//
//  Created by Chris Martin on 4/8/17.
//
//

import Foundation

public typealias GroupIdentifier = String
public struct Group {
    public var id: GroupIdentifier
    
    public init(from id: GroupIdentifier) {
        self.id = id
    }
}
