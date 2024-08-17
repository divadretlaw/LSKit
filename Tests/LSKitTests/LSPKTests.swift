import XCTest
@testable import LSKit

final class LSPKTests: XCTestCase {
    func testModFixer() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "ModFixer", withExtension: "pak"))
        let data = try LSPK(url: url)

        XCTAssertEqual(data.version, .v15)
        XCTAssertEqual(data.header.numberOfParts, 1)
        XCTAssertEqual(data.header.fileListOffset, 192)
        XCTAssertEqual(data.header.fileListSize, 90)

        let entry = try XCTUnwrap(data.entries.first)
        XCTAssertEqual(entry.name, "Mods/Gustav/Story/RawFiles/Goals/ForceRecompile.txt")
    }

    func testGoldWeightZero() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
        let data = try ModLSPK(url: url)

        XCTAssertEqual(data.version, .v18)
        XCTAssertEqual(data.header.numberOfParts, 1)
        XCTAssertEqual(data.header.fileListOffset, 1000)
        XCTAssertEqual(data.header.fileListSize, 113)

        let moduleInfo = try XCTUnwrap(data.meta.moduleInfo)
        let publishVersion = try XCTUnwrap(moduleInfo.publishVersion)
        XCTAssertEqual(publishVersion.uuid, "GOLDWEIG-HTZE-RO12-4444-deeeeeeeeeef")
        XCTAssertEqual(publishVersion.name, "Gold Weight Zero")
        XCTAssertEqual(publishVersion.folder, "Gold Weight Zero")
    }

    func testUnpack() throws {
        try XCTTemporaryDirectory { directory in
            let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
            let data = try ModLSPK(url: url)

            let directory = directory.appending(path: "Gold Weight Zero")
            try data.unpack(url: directory)
        }
    }

    func testPackAndRead() throws {
        try XCTTemporaryDirectory { directory in
            let unpacked = directory.appending(path: "Gold Weight Zero")
            let repacked = directory.appendingPathComponent("GWZ.pak")
            
            let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
            let pak = try LSPK(url: url)
            try pak.unpack(url: unpacked)

            let configuration = LSPKConfiguration(version: .v18, compressionMethod: .lz4)
            let generatedPak = try LSPK.pack(directory: unpacked, to: repacked, configuration: configuration)

            let readPak = try LSPK(url: generatedPak.url)

            // Check Header
            XCTAssertEqual(generatedPak.header.fileListOffset, readPak.header.fileListOffset)
            XCTAssertEqual(generatedPak.header.numberOfParts, readPak.header.numberOfParts)
            XCTAssertEqual(generatedPak.header.flags, readPak.header.flags)
            XCTAssertEqual(generatedPak.header.priority, readPak.header.priority)
            XCTAssertEqual(generatedPak.header.flags, readPak.header.flags)
            XCTAssertEqual(generatedPak.header.md5, readPak.header.md5)
            // Check entries
            XCTAssertEqual(generatedPak.entries.sorted(), readPak.entries.sorted())
        }
    }

    func testReadAllMods() throws {
        let bg3 = URL.homeDirectory.appending(path: "Library/Application Support/Baldur's Gate 3", directoryHint: .isDirectory)
        guard try bg3.checkResourceIsReachable() else {
            print("Baldur's Gate 3 is not installed on this machine")
            return
        }

        let mods = bg3.appending(path: "Mods", directoryHint: .isDirectory)
        guard let enumerator = FileManager.default.enumerator(at: mods, includingPropertiesForKeys: nil) else {
            return
        }

        var lspks: [LSPK] = []
        for case let url as URL in enumerator where url.pathExtension == "pak" {
            let lspk = try LSPK(url: url)
            lspks.append(lspk)
        }
        print("Number of mods:", lspks.count)
    }
    
    func testZSTD() throws {
        try XCTTemporaryDirectory { directory in
            let directory = directory.appending(path: "ZSTD-Test")
            let unpacked = directory.appending(path: "unpacked")
            let repacked = directory.appending(path: "repacked.pak")
            
            // Unpack a mod
            let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
            let data = try LSPK(url: url)
            try data.unpack(url: unpacked)
            // Package the unpacked mod, but with ZSTD compression
            let configuration = LSPKConfiguration(version: .v18, compressionMethod: .zstd, priority: 0)
            let generatedPak = try LSPK.pack(directory: unpacked, to: repacked, configuration: configuration)
            let readPak = try ModLSPK(url: generatedPak.url)
            // Check if data is still intact
            XCTAssertEqual(readPak.version, .v18)
            XCTAssertEqual(readPak.header.numberOfParts, 1)
            let moduleInfo = try XCTUnwrap(readPak.meta.moduleInfo)
            let publishVersion = try XCTUnwrap(moduleInfo.publishVersion)
            XCTAssertEqual(publishVersion.uuid, "GOLDWEIG-HTZE-RO12-4444-deeeeeeeeeef")
            XCTAssertEqual(publishVersion.name, "Gold Weight Zero")
            XCTAssertEqual(publishVersion.folder, "Gold Weight Zero")
        }
    }
}
