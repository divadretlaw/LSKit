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
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
        let data = try ModLSPK(url: url)

        try data.unpack(url: URL.homeDirectory.appendingPathComponent("mod"))
    }

    func testPackAndRead() throws {
        let directory = URL.homeDirectory.appendingPathComponent("mod")
        let file = URL.homeDirectory.appendingPathComponent("mod.pak")
        let generatedPak = try LSPK.pack(to: file, from: directory, version: .v18)

        let readPak = try LSPK(url: generatedPak.url)

        // Check Header
        XCTAssertEqual(generatedPak.header.fileListOffset, readPak.header.fileListOffset)
        XCTAssertEqual(generatedPak.header.numberOfParts, readPak.header.numberOfParts)
        XCTAssertEqual(generatedPak.header.flags, readPak.header.flags)
        // XCTAssertEqual(generatedPak.header.priority, readPak.header.priority)
        // XCTAssertEqual(generatedPak.header.flags, readPak.header.flags)
        XCTAssertEqual(generatedPak.header.md5, readPak.header.md5)
        // XCTAssertEqual(generatedPak.header.numberOfFiles, readPak.header.numberOfFiles)
        // XCTAssertEqual(generatedPak.header.dataOffset, readPak.header.dataOffset)
        // Check entries
        XCTAssertEqual(generatedPak.entries.sorted(), readPak.entries.sorted())
    }
}
