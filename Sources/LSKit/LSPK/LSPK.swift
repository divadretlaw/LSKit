//
//  LSPK.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation
import BinaryUtils
import libzstd

public protocol LSPKProtocol: Hashable, Equatable, Sendable {
    /// The location of the file
    var url: URL { get }
    /// The signature of the LSPK file. Must be "LSPK"
    var signature: UInt32 { get }
    /// The version of the LSPK file
    var version: LSPKVersion { get }

    /// The header of the LSPK file
    var header: LSPKHeader { get }
    /// The file entries in the LSPK file
    var entries: [LSPKFileEntry] { get }

    /// Load the LSPK file from the given url
    ///
    /// - Parameter url: The location of the file
    init(url: URL) throws

    /// Read the content of the given file entry
    ///
    /// - Parameter entry: The file entry to read from.
    ///
    /// - Returns: The data of the file entry.
    func contentsOf(entry: LSPKFileEntry) throws -> Data?

    /// Unpack the LSPK to the given location
    ///
    /// - Parameters:
    ///     - url: The location where the unpacked data should be
    ///     - progress: Progress callback
    func unpack(url: URL, progress: ((Double) -> Void)?) async throws

    /// Pack a directory as LSPK
    ///
    /// - Parameters:
    ///   - directory: The directory the pak file should be created from.
    ///   - url: The destination of the pak file.
    ///   - configuration: How the PAK should be created.
    ///   - progress: Progress callback
    static func pack(directory: URL, to url: URL, configuration: LSPKConfiguration, progress: ((Double) -> Void)?) async throws -> Self
}

public extension LSPKProtocol {
    init?(url: URL?) throws {
        guard let url else { return nil }
        try self.init(url: url)
    }

    func unpack(url: URL) async throws {
        try await unpack(url: url, progress: nil)
    }

    static func pack(directory: URL, configuration: LSPKConfiguration) async throws -> Self {
        let url = directory.appendingPathExtension("pak")
        return try await pack(directory: directory, to: url, configuration: configuration)
    }

    static func pack(directory: URL, to url: URL, configuration: LSPKConfiguration) async throws -> Self {
        try await pack(directory: directory, to: url, configuration: configuration, progress: nil)
    }
}

/// A LSPK file
public struct LSPK: LSPKProtocol {
    public let url: URL

    public let signature: UInt32
    public let version: LSPKVersion

    public let header: LSPKHeader
    public let entries: [LSPKFileEntry]

    internal init(url: URL, version: LSPKVersion, header: LSPKHeader, entries: [LSPKFileEntry]) {
        self.url = url
        self.signature = 0x4C53504B
        self.version = version
        self.header = header
        self.entries = entries
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
            guard let compressed = try fileHandle.read(fromByteOffset: entry.offsetInFile, upToCount: entry.sizeOnDisk) else {
                return nil
            }
            return try compressed.withUnsafeBytes { sourceBuffer -> Data? in
                let maxBound = ZSTD_getFrameContentSize(sourceBuffer.baseAddress, compressed.count)
                if maxBound == ZSTD_CONTENTSIZE_ERROR || maxBound == ZSTD_CONTENTSIZE_UNKNOWN {
                    throw CocoaError(CocoaError.Code(rawValue: 5377))
                }
                guard maxBound > 0 else {
                    throw CocoaError(CocoaError.Code(rawValue: 5377))
                }
                let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(maxBound))
                let decompressedSize = ZSTD_decompress(destinationBuffer, Int(maxBound), sourceBuffer.baseAddress, compressed.count)
                return Data(bytesNoCopy: destinationBuffer, count: decompressedSize, deallocator: .free)
            }
        }
    }
}
