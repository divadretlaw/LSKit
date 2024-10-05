//
//  LSPK+Pack.swift
//  LSKit
//
//  Created by David Walter on 10.08.24.
//

import Foundation
import BinaryUtils
import libzstd

extension LSPK {
    public static func pack(
        directory: URL,
        to url: URL,
        configuration: LSPKConfiguration,
        progress: ((Double) -> Void)?
    ) async throws -> Self {
        try Task.checkCancellation()

        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey], options: [.skipsHiddenFiles], errorHandler: nil) else {
            throw CocoaError(.fileReadUnknown)
        }

        try Data().write(to: url, options: [])
        let pak = try FileHandle(forWritingTo: url)
        let encoder = BinaryEncoder()
        encoder.stringEncodingStrategy = .fixedSize(256)

        // MARK: - Header

        try Task.checkCancellation()
        progress?(0.0)

        // Write LSPK signature
        try pak.write(contentsOf: Data([0x4C, 0x53, 0x50, 0x4B]))
        // Write LSPK version
        try pak.write(contentsOf: encoder.encode(configuration.version))

        // Write empty header to reserve space
        let headerOffset = try pak.offset()
        guard let actualHeader = configuration.emptyHeader() else {
            throw LSPKError.invalidFile("Unable to encode header with desired version")
        }
        try pak.write(contentsOf: encoder.encode(actualHeader))

        // MARK: - File Entries

        try Task.checkCancellation()
        progress?(0.01)

        // Determine entry file urls
        var entryUrls: [URL] = []
        for case let entryUrl as URL in enumerator {
            let resourceValues = try entryUrl.resourceValues(forKeys: resourceKeys)
            guard resourceValues.isDirectory == false else {
                continue
            }
            entryUrls.append(entryUrl)
        }
        entryUrls.sort { lhs, rhs in
            lhs.absoluteString < rhs.absoluteString
        }

        let total = Double(entryUrls.count) + 1 + 1 // Files + Header + File Entry List

        // Write contents of file entries
        var entries: [LSPKFileEntry] = []
        for entryUrl in entryUrls {
            try Task.checkCancellation()
            progress?(Double(entries.count + 1) / total)
            await Task.yield()

            let uncompressedData = try Data(contentsOf: entryUrl)
            let compressedData = switch configuration.compressionMethod {
            case .none:
                uncompressedData
            case .zlib:
                try uncompressedData.compressed(using: .zlib)
            case .lz4:
                try uncompressedData.compressed(using: .lz4raw)
            case .zstd:
                try uncompressedData.withUnsafeBytes { sourceBuffer -> Data in
                    let capacity = Swift.max(uncompressedData.count, 128)
                    let level = ZSTD_defaultCLevel()

                    let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
                    let compressedSize = ZSTD_compress(destinationBuffer, capacity, sourceBuffer.baseAddress, uncompressedData.count, level)
                    if ZSTD_isError(compressedSize) != 0 {
                        throw CocoaError(CocoaError.Code(rawValue: 5377))
                    }
                    return Data(bytesNoCopy: destinationBuffer, count: compressedSize, deallocator: .free)
                }
            }

            let offset = try pak.offset()
            try pak.write(contentsOf: compressedData)

            let crc: UInt = if configuration.version.hasCrc {
                compressedData.crc32()
            } else {
                0
            }

            let name = entryUrl.path
                .replacingOccurrences(of: directory.path, with: "")
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

            let entry = LSPKFileEntry(
                name: name,
                archivePart: 0, // TODO: What value to set?
                crc: UInt32(crc),
                compressionMethod: configuration.compressionMethod,
                compressionLevel: configuration.compressionLevel,
                offsetInFile: offset,
                sizeOnDisk: UInt64(compressedData.count),
                uncompressedSize: UInt64(uncompressedData.count)
            )
            entries.append(entry)
        }

        // MARK: - File Entry List

        try Task.checkCancellation()
        progress?(Double(entries.count + 1) / total)

        let fileListOffset = try pak.offset()
        // Gather file entry list data
        var joinedEntryData = Data()
        for entry in entries {
            guard let actualEntry = configuration.version.fileEntryType.init(entry: entry) else {
                throw LSPKError.invalidFile("Unable to encode file entry with desired version")
            }

            joinedEntryData += try encoder.encode(actualEntry)
        }
        // Compress file entry list if needed
        let rawFileListData = if configuration.version.hasCompressedFileEntryList {
            try joinedEntryData.compressed(using: .lz4raw)
        } else {
            joinedEntryData
        }
        // Add file entry list metadata if needed
        let fileListData = if configuration.version.hasCompressedFileEntryList {
            Data(UInt32(entries.count)) + Data(UInt32(rawFileListData.count)) + rawFileListData
        } else {
            rawFileListData
        }
        try pak.write(contentsOf: fileListData)

        // MD5 is computed over the contents of all files in an alphabetically sorted order
        let md5 = try MD5(urls: entryUrls.sorted(by: \.absoluteString))

        // Write actual header
        let header = LSPKHeader(
            fileListOffset: fileListOffset,
            fileListSize: UInt32(fileListData.count),
            flags: 0,
            priority: configuration.priority,
            md5: md5,
            numberOfParts: 1,
            numberOfFiles: entries.count,
            dataOffset: configuration.version.headerType.size + 8 // Signature + Version
        )
        guard let actualHeader = configuration.version.headerType.init(header: header) else {
            throw LSPKError.invalidFile("Unable to encode header with desired version")
        }
        try pak.seek(toOffset: headerOffset)
        try pak.write(contentsOf: encoder.encode(actualHeader))

        progress?(1)

        // Create LSPK
        return Self(url: url, version: configuration.version, header: header, entries: entries)
    }
}
