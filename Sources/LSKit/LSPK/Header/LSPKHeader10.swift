//
//  LSPKHeader15.swift
//  LSKit
//
//  Created by David Walter on 23.07.24.
//

import Foundation
import BinaryUtils

struct LSPKHeader10: Hashable, Equatable, Codable, Sendable {
    let dataOffset: UInt32
    let fileListSize: UInt32
    let numberOfParts: UInt16
    let flags: UInt8
    let priority: UInt8
    let numberOfFiles: UInt32
    
    init?(header: LSPKHeader) {
        guard let dataOffset = header.dataOffset, let numberOfFiles = header.numberOfFiles else { return nil }
        self.dataOffset = UInt32(dataOffset)
        self.fileListSize = header.fileListSize
        guard let parts = UInt16(exactly: header.numberOfParts) else { return nil }
        self.numberOfParts = parts
        self.flags = header.flags
        self.priority = header.priority
        self.numberOfFiles = UInt32(numberOfFiles)
    }
}

extension LSPKHeader {
    init(header: LSPKHeader10) {
        self.fileListOffset = UInt64(MemoryLayout<LSPKHeader10>.size)
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = MD5()
        self.numberOfParts = Int(header.numberOfParts)
        self.numberOfFiles = Int(header.numberOfFiles)
        self.dataOffset = Int(header.dataOffset)
    }
}
