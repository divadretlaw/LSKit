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

    init?(entry: LSPKFileEntry) {
        self.name = entry.name
        self.offsetInFile1 = UInt32(entry.offsetInFile & 0x00000000FFFFFFFF)
        self.offsetInFile2 = UInt16(entry.offsetInFile >> 32)
        guard let archivePart = UInt8(exactly: entry.archivePart) else {
            return nil
        }
        self.archivePart = archivePart
        self.flags = entry.flags
        self.sizeOnDisk = UInt32(entry.sizeOnDisk)
        self.uncompressedSize = UInt32(entry.uncompressedSize)
    }
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
