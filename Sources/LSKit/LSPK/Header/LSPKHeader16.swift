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
    let parts: UInt16
}

extension LSPKHeader {
    init(header: LSPKHeader16) {
        self.fileListOffset = header.fileListOffset
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = header.md5
        self.parts = Int(header.parts)
    }
}
