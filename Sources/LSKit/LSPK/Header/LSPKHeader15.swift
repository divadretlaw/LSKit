//
//  LSPKHeader15.swift
//  LSKit
//
//  Created by David Walter on 23.07.24.
//

import Foundation
import BinaryUtils

struct LSPKHeader15: Hashable, Equatable, Codable, Sendable {
    let fileListOffset: UInt64
    let fileListSize: UInt32
    let flags: UInt8
    let priority: UInt8
    let md5: MD5

    init?(header: LSPKHeader) {
        guard header.numberOfParts == 1 else { return nil }
        self.fileListOffset = header.fileListOffset
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = header.md5
    }
}

extension LSPKHeader {
    init(header: LSPKHeader15) {
        self.fileListOffset = header.fileListOffset
        self.fileListSize = header.fileListSize
        self.flags = header.flags
        self.priority = header.priority
        self.md5 = header.md5
        self.numberOfParts = 1
        self.numberOfFiles = nil
        self.dataOffset = nil
    }
}
