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
    public let priority: UInt32

    public init(
        version: LSPKVersion,
        compressionMethod: LSPKFileEntry.CompressionMethod,
        priority: UInt32 = 0
    ) {
        self.version = version
        self.compressionMethod = compressionMethod
        self.priority = priority
    }

    var emptyHeader: (any LSPKHeaderRepresentable)? {
        version.headerType.init(header: LSPKHeader.empty(version: version))
    }
}
