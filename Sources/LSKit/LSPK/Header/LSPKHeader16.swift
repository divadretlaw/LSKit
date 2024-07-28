//
//  LSPK+eader16.swift
//  LSKit
//
//  Created by David Walter on 22.07.24.
//

import Foundation
import BinaryUtils

struct LSPKHeader16: Hashable, Equatable, Codable, Sendable {
    let fileListOffset: UInt64
    let fileListSize: UInt32
    let flags: UInt8
    let priority: UInt8
    let md5: MD5
    let numberOfParts: UInt16
    
    init?(header: LSPKHeader) {
        self.fileListOffset = header.fileListOffset
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = header.md5
        self.numberOfParts = UInt16(header.numberOfParts)
    }
}

extension LSPKHeader {
    init(header: LSPKHeader16) {
        self.fileListOffset = header.fileListOffset
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = header.md5
        self.numberOfParts = Int(header.numberOfParts)
        self.numberOfFiles = nil
        self.dataOffset = nil
    }
}
