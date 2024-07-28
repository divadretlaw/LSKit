//
//  LSPKFileEntry18.swift
//  LSKit
//
//  Created by David Walter on 22.07.24.
//

import Foundation

struct LSPKFileEntry18: LSPKFileEntryRepresentable, Hashable, Equatable, Codable, Sendable {
    static var size: Int {
        272
    }

    let name: String
    let offsetInFile1: UInt32
    let offsetInFile2: UInt16
    let archivePart: UInt8
    let flags: UInt8
    let sizeOnDisk: UInt32
    let uncompressedSize: UInt32
}

extension LSPKFileEntry {
    init(entry: LSPKFileEntry18) {
        self.name = entry.name
        self.archivePart = UInt32(entry.archivePart)
        self.crc = 0
        self.compressionMethod = CompressionMethod(rawValue: UInt8(entry.flags & 0x0F) ) ?? .none
        self.compressionLevel = CompressionLevel(rawValue: UInt8(entry.flags & 0xF0)) ?? .default
        let offsetInFile = entry.offsetInFile1 | UInt32(entry.offsetInFile2) << 32
        self.offsetInFile = UInt64(offsetInFile)
        self.sizeOnDisk = UInt64(entry.sizeOnDisk)
        self.uncompressedSize = UInt64(entry.uncompressedSize)
    }
}
