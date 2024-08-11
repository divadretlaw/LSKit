//
//  LSXVersion.swift
//  LSKit
//
//  Created by David Walter on 21.07.24.
//

import Foundation

/// The version of an ``LSX`` file
public struct LSXVersion: Hashable, Equatable, Codable, Sendable, XmlConvertible, CustomStringConvertible {
    public let major: String?
    public let minor: String?
    public let revision: String?
    public let build: String?

    init() {
        self.major = nil
        self.minor = nil
        self.revision = nil
        self.build = nil
    }

    init(major: String, minor: String, revision: String, build: String) {
        self.major = major
        self.minor = minor
        self.revision = revision
        self.build = build
    }

    init(attributes: [String: String]) {
        self.major = attributes["major"]
        self.minor = attributes["minor"]
        self.revision = attributes["revision"]
        self.build = attributes["build"]
    }

    static var empty: Self {
        Self()
    }

    // MARK: - XmlConvertible

    public var xmlDescription: String {
        "<version major=\"\(major ?? "")\" minor=\"\(minor ?? "")\" revision=\"\(revision ?? "")\" build=\"\(build ?? "")\"/>"
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        [major, minor, revision, build].compactMap { $0 }.joined(separator: ".")
    }
}
