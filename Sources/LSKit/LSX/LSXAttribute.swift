//
//  LSXAttribute.swift
//  LSKit
//
//  Created by David Walter on 21.07.24.
//

import Foundation

/// A node object of `attribute` in an ``LSX`` file
public struct LSXAttribute: Hashable, Equatable, Codable, Sendable, XmlConvertible, CustomStringConvertible {
    /// The id of the node
    public let id: String
    /// The value of the node
    public let value: String
    /// The type of the node
    public let type: String

    public init?(attributes: [String: String]) {
        guard let id = attributes["id"], let type = attributes["type"] else { return nil }
        self.id = id
        self.value = attributes["value"] ?? ""
        self.type = type
    }

    // MARK: - XmlConvertible

    public var xmlDescription: String {
        "<attribute id=\"\(id)\" type=\"\(type)\" value=\"\(value)\"/>"
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        "Attribute \(id): \"\(value)\" (\(type))"
    }
}

public extension [LSXAttribute] {
    func value(forKey key: String) -> String? {
        first { $0.id == key }?.value
    }
}
