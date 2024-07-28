//
//  LSXAttribute.swift
//  LSKit
//
//  Created by David Walter on 21.07.24.
//

import Foundation

public struct LSXAttribute: Hashable, Equatable, Codable, Sendable, XmlConvertible, CustomStringConvertible {
    public let id: String
    public let value: String
    public let type: String

    public init?(attributes: [String: String]) {
        guard let id = attributes["id"], let type = attributes["type"] else { return nil }
        self.id = id
        self.value = attributes["value"] ?? ""
        self.type = type
    }

    // MARK: - XmlConvertible

    public func xml() -> String {
        "<attribute id=\"\(id)\" type=\"\(type)\" value=\"\(value)\"/>"
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        "Attribute \(id): \"\(value)\" (\(type))"
    }
}
