//
//  LSPKConfiguration.swift
//  LSKit
//
//  Created by David Walter on 05.08.24.
//

import Foundation

public struct LSPKConfiguration: Sendable {
    public let version: LSPKVersion
    public let compressionMethod: LSPKFileEntry.CompressionMethod
    let compressionLevel: LSPKFileEntry.CompressionLevel
    public let priority: UInt8

    public init(
        version: LSPKVersion,
        compressionMethod: LSPKFileEntry.CompressionMethod = .lz4,
        priority: UInt8 = 0
    ) {
        self.version = version
        self.compressionMethod = compressionMethod
        self.priority = priority
        
        switch compressionMethod {
        case .none:
            compressionLevel = .default
        case .zlib:
            compressionLevel = .default
        case .lz4:
            compressionLevel = .fast
        case .zstd:
            compressionLevel = .default
        }
    }

    func emptyHeader() -> (any LSPKHeaderRepresentable)? {
        version.headerType.init(header: LSPKHeader.empty(version: version))
    }
}
