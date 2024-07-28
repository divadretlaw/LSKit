//
//  LSPKFileEntry+Compression.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation

extension LSPKFileEntry {
    /// Compression levels for LSKP file entries
    public enum CompressionLevel: UInt8, Hashable, Equatable, Sendable {
        case fast = 0x10
        case `default` = 0x20
        case max = 0x40
    }
    
    /// Compression methods for LSKP file entries
    public enum CompressionMethod: UInt8, Hashable, Equatable, Sendable {
        case none = 0x00
        case zlib = 0x01
        case lz4 = 0x02
        case zstd = 0x03
    }
}
