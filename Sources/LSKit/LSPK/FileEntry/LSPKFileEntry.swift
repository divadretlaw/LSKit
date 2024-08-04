//
//  LSPKFileEntry.swift
//  LSKit
//
//  Created by David Walter on 24.07.24.
//

import Foundation
import BinaryUtils

public protocol LSPKFileEntryRepresentable: Codable {
    /// The binary size of the file entry
    static var size: Int { get }

    init?(entry: LSPKFileEntry)
}

/// A LSPK file entry contains metadata needed to read the actual files contained in the LSPK file
public struct LSPKFileEntry: Hashable, Equatable, Comparable, Sendable {
    /// The path of the file entry
    public let name: String
    public let archivePart: UInt32
    public let crc: UInt32
    /// The compression method used to compress the file entry
    public let compressionMethod: CompressionMethod
    /// The compression level used to compress the file entry
    public let compressionLevel: CompressionLevel
    public let offsetInFile: UInt64
    /// The size on disk of the file entry
    public let sizeOnDisk: UInt64
    /// The uncompressed size of the file entry
    public let uncompressedSize: UInt64

    var flags: UInt8 {
        compressionLevel.rawValue | compressionMethod.rawValue
    }

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
        try fileHandle.seek(toOffset: offset)

        if version.hasCompressedFileEntryList {
            let numberOfFiles = try fileHandle.read(type: UInt32.self) ?? 0

            let decompressedSize = version.fileEntryType.size * Int(numberOfFiles)

            let compressedSize = try fileHandle.read(type: UInt32.self) ?? 0

            guard let compressed = try fileHandle.read(upToCount: Int(compressedSize)) else {
                throw CocoaError(.fileReadUnknown)
            }

            let decompressed = try compressed.decompressed(using: .lz4raw(decompressedSize))

            return try read(version, data: decompressed.chunked(size: version.fileEntryType.size))
        } else {
            guard let data = try fileHandle.readToEnd() else {
                throw CocoaError(.fileReadUnknown)
            }

            return try read(version, data: data.chunked(size: version.fileEntryType.size))
        }
    }

    // MARK: - Comparable

    public static func < (lhs: LSPKFileEntry, rhs: LSPKFileEntry) -> Bool {
        lhs.name < rhs.name
    }
}
