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
            let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
            let pak = try LSPK(url: url)
            let directory = directory.appending(path: "Gold Weight Zero")
            try pak.unpack(url: directory)

            let configuration = LSPKConfiguration(version: .v18, compressionMethod: .lz4)

            let file = URL.homeDirectory.appendingPathComponent("GWZ.pak")
            let generatedPak = try LSPK.pack(to: file, from: directory, configuration: configuration)

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
}
