//
//  LSX.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

public protocol LSXProtocol: Hashable, Equatable, Sendable, XmlConvertible {
    var version: LSXVersion { get }
    var regions: [LSXRegion] { get }
    
    init?(url: URL) throws
    init?(data: Data)
}

public struct LSX: LSXProtocol, Codable {
    public let version: LSXVersion
    public let regions: [LSXRegion]
    
    public init?(url: URL) throws {
        let data = try Data(contentsOf: url)
        self.init(data: data)
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
