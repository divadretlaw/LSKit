//
//  LSPK.swift
//  LSKit
//
//  Created by David Walter on 27.07.24.
//

import Foundation
import BinaryUtils

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
    /// - Parameter url: The location where the unpacked data should be
    func unpack(url: URL) throws

    /// Pack a directory as LSPK
    ///
    /// - Parameters:
    ///   - url: The destination of the pak file.
    ///   - directory: The directory the pak file should be created from.
    ///   - configuration: How the PAK should be created.
    ///
    /// > Warning:
    /// > This is a work in progress
    static func pack(to url: URL, from directory: URL, configuration: LSPKConfiguration) throws -> Self
}

public extension LSPKProtocol {
    init?(url: URL?) throws {
        guard let url else { return nil }
        try self.init(url: url)
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

    public static func pack(to url: URL, from directory: URL, configuration: LSPKConfiguration) throws -> Self {
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey], options: [.skipsHiddenFiles], errorHandler: nil) else {
            throw CocoaError(.fileReadUnknown)
        }

        try Data().write(to: url, options: [])
        let pak = try FileHandle(forWritingTo: url)
        let encoder = BinaryEncoder()
        encoder.stringEncodingStrategy = .fixedSize(256)

        try pak.write(contentsOf: Data([0x4C, 0x53, 0x50, 0x4B]))
        try pak.write(contentsOf: encoder.encode(configuration.version))

        // Write empty header to reserve space
        let headerOffset = try pak.offset()
        guard let actualHeader = configuration.emptyHeader else {
            throw LSPKError.invalidFile("Unable to encode header with desired version")
        }
        try pak.write(contentsOf: encoder.encode(actualHeader))

        // Write contents of file entries
        var urls: [URL] = []
        var entries: [LSPKFileEntry] = []
        for case let url as URL in enumerator {
            let resourceValues = try url.resourceValues(forKeys: resourceKeys)
            guard resourceValues.isDirectory == false else {
                continue
            }

            let uncompressedData = try Data(contentsOf: url)
            let compressedData = switch configuration.compressionMethod {
            case .none:
                uncompressedData
            case .zlib:
                try uncompressedData.compressed(using: .zlib)
            case .lz4:
                try uncompressedData.compressed(using: .lz4raw)
            case .zstd:
                throw LSPKError.notSupported("Compression Method ZSTD is currently not supported")
            }

            let offset = try pak.offset()
            try pak.write(contentsOf: compressedData)

            let crc: UInt = if configuration.version.hasCrc {
                compressedData.crc32()
            } else {
                0
            }

            let entry = LSPKFileEntry(
                name: url.path,
                archivePart: 0, // TODO: What value to set?
                crc: UInt32(crc),
                compressionMethod: configuration.compressionMethod,
                compressionLevel: .default, // TODO: Supported different levels
                offsetInFile: offset,
                sizeOnDisk: UInt64(compressedData.count),
                uncompressedSize: UInt64(uncompressedData.count)
            )
            urls.append(url)
            entries.append(entry)
        }

        // MD5 is computed over the contents of all files in an alphabetically sorted order
        let md5 = try MD5(urls: urls.sorted { lhs, rhs in
            lhs.absoluteString < rhs.absoluteString
        })

        let fileListOffset = try pak.offset()

        // Write file entries
        var fileListData = Data()
        for entry in entries {
            guard let actualEntry = configuration.version.fileEntryType.init(entry: entry) else {
                throw LSPKError.invalidFile("Unable to encode file entry with desired version")
            }

            fileListData += try encoder.encode(actualEntry)
        }

        // Write actual file entry list metadata to reserve space
        if configuration.version.hasCompressedFileEntryList {
            try pak.write(contentsOf: Data(UInt32(entries.count)))
            let compressedData = try fileListData.compressed(using: .lz4raw)
            try pak.write(contentsOf: Data(UInt32(compressedData.count)))
            try pak.write(contentsOf: compressedData)
        } else {
            try pak.write(contentsOf: fileListData)
        }

        // Write actual header
        let flags: UInt8 = if configuration.version.hasCompressedFileEntryList {
            LSPKFileEntry.CompressionMethod.lz4.rawValue | LSPKFileEntry.CompressionLevel.default.rawValue
        } else {
            0
        }

        let header = LSPKHeader(
            fileListOffset: fileListOffset,
            fileListSize: UInt32(entries.count),
            flags: flags,
            priority: 0,
            md5: md5,
            numberOfParts: entries.count,
            numberOfFiles: entries.count,
            dataOffset: configuration.version.headerType.size + 8
        )
        guard let actualHeader = configuration.version.headerType.init(header: header) else {
            throw LSPKError.invalidFile("Unable to encode header with desired version")
        }
        try pak.seek(toOffset: headerOffset)
        try pak.write(contentsOf: encoder.encode(actualHeader))

        // Create LSPK instance
        return Self(url: url, version: configuration.version, header: header, entries: entries)
    }
}
