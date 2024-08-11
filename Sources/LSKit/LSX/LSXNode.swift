//
//  LSXNode.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

/// A node object of `node` in an ``LSX`` file
public struct LSXNode: Hashable, Equatable, Codable, Sendable, XmlConvertible, CustomStringConvertible {
    /// The id of the node
    public let id: String
    /// The attributes of the node
    public let attributes: [LSXAttribute]
    /// The children of the node
    public let children: [LSXNode]

    init(id: String, attributes: [LSXAttribute], children: [LSXNode]) {
        self.id = id
        self.attributes = attributes
        self.children = children
    }

    // MARK: - XmlConvertible

    public var xmlDescription: String {
        let attributes = attributes
            .map(\.xmlDescription)
            .joined(separator: "\n")

        let children = xmlChildren()

        return """
        <node id=\"\(id)\">
        \(attributes.indent())
        \(children.indent())
        </node>
        """
    }

    private func xmlChildren() -> String {
        guard !children.isEmpty else { return "" }
        let children = children
            .map(\.xmlDescription)
            .joined(separator: "\n")

        return """
        <children>
        \(children.indent())
        </children>
        """
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        "Node \(id): attributes=\(attributes) children=\(children)"
    }
}
