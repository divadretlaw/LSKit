//
//  LSPKHeader.swift
//  LSKit
//
//  Created by David Walter on 23.07.24.
//

import Foundation
import BinaryUtils

protocol LSPKHeaderRepresentable: Codable {
    /// The binary size of the file entry
    static var size: Int { get }

    init?(header: LSPKHeader)
}

/// The header of an LSPK file contains metadata needed to read the LSPK file
public struct LSPKHeader: Hashable, Equatable, Sendable {
    /// The offset of the file entry list
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

    static func empty(version: LSPKVersion) -> Self {
        let flags: UInt8 = if version.hasCompressedFileEntryList {
            LSPKFileEntry.CompressionMethod.lz4.rawValue | LSPKFileEntry.CompressionLevel.default.rawValue
        } else {
            0
        }
        return LSPKHeader(
            fileListOffset: 0,
            fileListSize: 0,
            flags: flags,
            priority: 0,
            md5: MD5(data: Data()),
            numberOfParts: 0,
            numberOfFiles: 0,
            dataOffset: version.headerType.size + 8
        )
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
