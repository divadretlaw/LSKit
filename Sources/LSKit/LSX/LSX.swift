//
//  LSX.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

public protocol LSXProtocol: Hashable, Equatable, Sendable, XmlConvertible {
    /// The version of the ``LSX`` file
    var version: LSXVersion { get }
    /// The region nodes of the ``LSX`` files
    var regions: [LSXRegion] { get }

    /// Load a LSX from the given url
    /// - Parameter data: The url to read from.
    /// - Returns: The loaded ``LSX`` or `nil` if the given data couldn't read or parsed
    init?(url: URL)
    /// Load a LSX from the given data
    /// - Parameter data: The data to read from.
    /// - Returns: The loaded ``LSX`` or `nil` if the given data couldn't be parsed
    init?(data: Data)
}

public struct LSX: LSXProtocol, Codable {
    public let version: LSXVersion
    public let regions: [LSXRegion]

    public init?(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            return nil
        }
    }

    public init?(data: Data) {
        let parser = XMLParser(data: data)
        let lsx = LSXParser()
        parser.delegate = lsx
        parser.parse()
        guard let result = lsx.result else { return nil }
        self = result
    }

    internal init() {
        self.version = .empty
        self.regions = []
    }

    init(version: LSXVersion, regions: [LSXRegion]) {
        self.version = version
        self.regions = regions
    }

    // MARK: - XmlConvertible

    public func xml() -> String {
        let regions = regions
            .map { value in
                value.xml()
            }
            .joined(separator: "\n")

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <save>
            \(version.xml())
        \(regions.indent())
        </save>
        """
    }
}
