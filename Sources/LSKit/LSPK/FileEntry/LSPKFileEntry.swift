//
//  LSPKFileEntry.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation
import BinaryUtils

public protocol LSPKFileEntryRepresentable {
    static var size: Int { get }
}

public struct LSPKFileEntry: Hashable, Equatable, Sendable {
    public let name: String
    public let archivePart: UInt32
    public let crc: UInt32
    public let compressionMethod: CompressionMethod
    public let compressionLevel: CompressionLevel
    public let offsetInFile: UInt64
    public let sizeOnDisk: UInt64
    public let uncompressedSize: UInt64
    
    static func read(_ version: LSPKVersion, data: [Data]) throws -> [LSPKFileEntry] {
        let decoder = BinaryDecoder()
        decoder.stringDecodingStrategy = .fixedSize(256)
        
        return switch version {
        case .v10:
            try data
                .map { try decoder.decode(LSPKFileEntry10.self, from: $0) }
                .map { LSPKFileEntry(entry: $0) }
        case .v15, .v16:
            try data
                .map { try decoder.decode(LSPKFileEntry15.self, from: $0) }
                .map { LSPKFileEntry(entry: $0) }
        case .v18:
            try data
                .map { try decoder.decode(LSPKFileEntry18.self, from: $0) }
                .map { LSPKFileEntry(entry: $0) }
        }
    }
    
    static func read(_ version: LSPKVersion, from fileHandle: FileHandle, with offset: UInt64) throws -> [LSPKFileEntry] {
        var offset = offset
        
        if version.hasCompressedFileEntryList {
            let numberOfFiles = try fileHandle.read(fromByteOffset: offset, type: UInt32.self) ?? 0
            offset.move(by: UInt32.self)
            
            let decompressedSize = version.fileEntryType.size * Int(numberOfFiles)
            
            try fileHandle.seek(toOffset: offset)
            let compressedSize = try fileHandle.read(fromByteOffset: offset, type: UInt32.self) ?? 0
            offset.move(by: UInt32.self)
            
            try fileHandle.seek(toOffset: offset)
            guard let compressed = try fileHandle.read(upToCount: Int(compressedSize)) else {
                throw CocoaError(.fileReadUnknown)
            }
            
            let decompressed = try compressed.decompressed(using: .lz4raw(decompressedSize))
            
            return try read(version, data: decompressed.chunked(size: version.fileEntryType.size))
        } else {
            guard let data = try fileHandle.readToEnd() else {
                throw CocoaError(.fileReadUnknown)
            }
            
            return try read(version, data: [data])
        }
    }
}
