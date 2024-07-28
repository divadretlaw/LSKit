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
    
    public let parts: Int
    
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
