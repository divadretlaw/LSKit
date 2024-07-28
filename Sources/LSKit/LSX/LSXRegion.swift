//
//  LSXRegion.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

public struct LSXRegion: Hashable, Equatable, Codable, Sendable, XmlConvertible, CustomStringConvertible {
    public let id: String
    public let nodes: [LSXNode]
    
    init(id: String) {
        self.id = id
        self.nodes = []
    }
    
    init(id: String, nodes: [LSXNode]) {
        self.id = id
        self.nodes = nodes
    }
    
    // MARK: - XmlConvertible
    
    public func xml() -> String {
        let nodes = nodes
            .map { value in
                value.xml()
            }
            .joined(separator: "\n")
        
        return """
        <region id=\"\(id)\">
        \(nodes.indent())
        </region>
        """
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        "Region \(id): nodes=\(nodes)"
    }
}
