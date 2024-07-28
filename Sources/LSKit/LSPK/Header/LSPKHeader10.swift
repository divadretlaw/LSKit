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
}

extension LSPKHeader {
    init(header: LSPKHeader10) {
        self.fileListOffset = UInt64(MemoryLayout<LSPKHeader10>.size)
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = MD5()
        self.parts = 1
    }
}
