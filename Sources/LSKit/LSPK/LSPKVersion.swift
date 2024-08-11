//
//  LSPKVersion.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation

public enum LSPKVersion: UInt32, Hashable, Equatable, Codable, Sendable {
    case v10 = 10
    case v15 = 15
    case v16 = 16
    case v18 = 18

    var hasCompressedFileEntryList: Bool {
        rawValue > 13
    }

    var hasCrc: Bool {
        (10...16).contains(rawValue)
    }

    var fileEntryCompressionMethod: LSPKFileEntry.CompressionMethod {
        switch self {
        case .v10:
            return .none
        case .v15:
            return .lz4
        case .v16:
            return .lz4
        case .v18:
            return .lz4
        }
    }

    var fileEntryCompressionLevel: LSPKFileEntry.CompressionLevel {
        switch self {
        case .v10:
            return .default
        case .v15:
            return .default
        case .v16:
            return .default
        case .v18:
            return .default
        }
    }

    var fileEntryType: LSPKFileEntryRepresentable.Type {
        switch self {
        case .v10:
            LSPKFileEntry10.self
        case .v15:
            LSPKFileEntry15.self
        case .v16:
            LSPKFileEntry18.self
        case .v18:
            LSPKFileEntry18.self
        }
    }

    var headerType: LSPKHeaderRepresentable.Type {
        switch self {
        case .v10:
            LSPKHeader10.self
        case .v15:
            LSPKHeader15.self
        case .v16, .v18:
            LSPKHeader16.self
        }
    }
}
