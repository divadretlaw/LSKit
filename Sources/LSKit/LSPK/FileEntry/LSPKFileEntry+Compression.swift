//
//  LSPKFileEntry+Compression.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation
import Compression

extension LSPKFileEntry {
    public enum CompressionLevel: UInt8, Hashable, Equatable, Sendable {
        case fast = 0x10
        case `default` = 0x20
        case max = 0x40
    }
    
    public enum CompressionMethod: UInt8, Hashable, Equatable, Sendable {
        case none = 0x00
        case zlib = 0x01
        case lz4 = 0x02
        case zstd = 0x03
        
        var algorithm: compression_algorithm? {
            switch self {
            case .none:
                return nil
            case .zlib:
                return COMPRESSION_ZLIB
            case .lz4:
                return COMPRESSION_LZ4_RAW
            case .zstd:
                return nil
            }
        }
    }
}
