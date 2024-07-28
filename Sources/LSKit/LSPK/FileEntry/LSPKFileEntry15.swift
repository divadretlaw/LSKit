//
//  LSPKFileEntry15.swift
//  LSKit
//
//  Created by David Walter on 22.07.24.
//

import Foundation

struct LSPKFileEntry15: LSPKFileEntryRepresentable, Hashable, Equatable, Codable, Sendable {
    static var size: Int {
        296
    }

    let name: String
    let offsetInFile: UInt64
    let sizeOnDisk: UInt64
    let uncompressedSize: UInt64
    let archivePart: UInt32
    let flags: UInt32
    let crc: UInt32
    let unknown: UInt32
}

extension LSPKFileEntry {
    init(entry: LSPKFileEntry15) {
        self.name = entry.name
        self.archivePart = entry.archivePart
        self.crc = entry.crc
        self.compressionMethod = CompressionMethod(rawValue: UInt8(entry.flags & 0x0F) ) ?? .none
        self.compressionLevel = CompressionLevel(rawValue: UInt8(entry.flags & 0xF0)) ?? .default
        self.offsetInFile = entry.offsetInFile
        self.sizeOnDisk = entry.sizeOnDisk
        self.uncompressedSize = entry.uncompressedSize
    }
}
