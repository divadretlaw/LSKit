//
//  LSPKHeader.swift
//  LSKit
//
//  Created by David Walter on 23.07.24.
//

import Foundation
import BinaryUtils

public struct LSPKHeader: Hashable, Equatable, Sendable {
    public let fileListOffset: UInt64
    public let fileListSize: UInt32
    public let flags: UInt8
    public let priority: UInt8
    public let md5: MD5
    
    public let numberOfParts: Int
    
    public let numberOfFiles: Int?
    public let dataOffset: Int?
    
    init(
        fileListOffset: UInt64,
        fileListSize: UInt32,
        flags: UInt8,
        priority: UInt8,
        md5: MD5,
        numberOfParts: Int = 1,
        numberOfFiles: Int? = nil,
        dataOffset: Int? = nil
    ) {
        self.fileListOffset = fileListOffset
        self.fileListSize = fileListSize
        self.flags = flags
        self.priority = priority
        self.md5 = md5
        self.numberOfParts = numberOfParts
        self.numberOfFiles = numberOfFiles
        self.dataOffset = dataOffset
    }
    
    
    static func read(_ version: LSPKVersion, from fileHandle: FileHandle, with offset: UInt64) throws -> LSPKHeader {
        try fileHandle.seek(toOffset: offset)
        
        let decoder = BinaryDecoder()
        
        switch version {
        case .v10:
            let header10 = try decoder.decode(LSPKHeader10.self, from: fileHandle)
            return LSPKHeader(header: header10)
        case .v15:
            let header15 = try decoder.decode(LSPKHeader15.self, from: fileHandle)
            return LSPKHeader(header: header15)
        case .v16, .v18:
            let header16 = try decoder.decode(LSPKHeader16.self, from: fileHandle)
            return LSPKHeader(header: header16)
        }
    }
}
