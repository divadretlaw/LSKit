//
//  LSPKFileEntry10.swift
//  LSKit
//
//  Created by David Walter on 22.07.24.
//

import Foundation

struct LSPKFileEntry10: LSPKFileEntryRepresentable, Hashable, Equatable, Codable, Sendable {
    static var size: Int {
        280
    }

    let name: String
    let offsetInFile: UInt32
    let sizeOnDisk: UInt32
    let uncompressedSize: UInt32
    let archivePart: UInt32
    let flags: UInt32
    let crc: UInt32

    init?(entry: LSPKFileEntry) {
        self.name = entry.name
        guard let offsetInFile = UInt32(exactly: entry.offsetInFile) else {
            return nil
        }
        self.offsetInFile = offsetInFile
        guard let sizeOnDisk = UInt32(exactly: entry.sizeOnDisk) else {
            return nil
        }
        self.sizeOnDisk = sizeOnDisk
        guard let uncompressedSize = UInt32(exactly: entry.uncompressedSize) else {
            return nil
        }
        self.uncompressedSize = uncompressedSize
        self.archivePart = entry.archivePart
        self.flags = UInt32(entry.flags)
        self.crc = entry.crc
    }
}

extension LSPKFileEntry {
    init(entry: LSPKFileEntry10) {
        self.name = entry.name
        self.archivePart = entry.archivePart
        self.crc = entry.crc
        self.compressionMethod = CompressionMethod(rawValue: UInt8(entry.flags & 0x0F) ) ?? .none
        self.compressionLevel = CompressionLevel(rawValue: UInt8(entry.flags & 0xF0)) ?? .default
        self.offsetInFile = UInt64(entry.offsetInFile)
        self.sizeOnDisk = UInt64(entry.sizeOnDisk)
        self.uncompressedSize = UInt64(entry.uncompressedSize)
    }
}
