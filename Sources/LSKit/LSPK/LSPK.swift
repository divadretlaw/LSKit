//
//  LSPK.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation

public protocol LSPKProtocol: Hashable, Equatable, Sendable {
    var signature: UInt32 { get }
    var version: LSPKVersion { get }
    
    var header: LSPKHeader { get }
    var entries: [LSPKFileEntry] { get }
    
    init?(url: URL) throws
    
    func contentsOf(entry: LSPKFileEntry) throws -> Data?
    func unpack(url: URL) throws
}

public struct LSPK: LSPKProtocol {
    public let url: URL
    
    public let signature: UInt32
    public let version: LSPKVersion
    
    public let header: LSPKHeader
    public let entries: [LSPKFileEntry]
    
    public init?(url: URL?) throws {
        guard let url else { return nil }
        try self.init(url: url)
    }
    
    public init(url: URL) throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer {
            try? fileHandle.close()
        }
        
        self.url = url
        
        var offset: UInt64 = 0
        
        let signature = try fileHandle.read(fromByteOffset: offset, type: UInt32.self) ?? 0
        // Check signature ("LSPK")
        guard signature.bigEndian == 0x4C53504B else {
            throw LSPKError.invalidFile("Invalid LSPK file signature. Abort.")
        }
        offset.move(by: UInt32.self)
        self.signature = signature
        
        guard let version = try fileHandle.read(fromByteOffset: offset, type: LSPKVersion.self) else {
            throw LSPKError.notSupported("This specific version is not supported.")
        }
        offset.move(by: version)
        self.version = version
        
        self.header = try LSPKHeader.read(version, from: fileHandle, with: offset)
        self.entries = try LSPKFileEntry.read(version, from: fileHandle, with: header.fileListOffset)
    }
    
    public func contentsOf(entry: LSPKFileEntry) throws -> Data? {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer {
            try? fileHandle.close()
        }
        
        switch entry.compressionMethod {
        case .none:
            return try fileHandle.read(fromByteOffset: entry.offsetInFile, upToCount: entry.sizeOnDisk)
        case .zlib:
            guard let compressed = try fileHandle.read(fromByteOffset: entry.offsetInFile, upToCount: entry.sizeOnDisk) else {
                return nil
            }
            return try compressed.decompressed(using: .zlib)
        case .lz4:
            guard let compressed = try fileHandle.read(fromByteOffset: entry.offsetInFile, upToCount: entry.sizeOnDisk) else {
                return nil
            }
            return try compressed.decompressed(using: .lz4raw(Int(entry.uncompressedSize)))
        case .zstd:
            throw LSPKError.notSupported("Compression Method ZSTD is currently not supported")
        }
    }
    
    public func unpack(url: URL) throws {
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        for entry in entries {
            guard let content = try contentsOf(entry: entry) else { continue }
            let file = url.appendingPathComponent(entry.name)
            try? FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            try content.write(to: file)
        }
    }
}
