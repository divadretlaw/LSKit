import XCTest
@testable import LSKit
import Compression

final class LSPKTests: XCTestCase {
    func testModFixer() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "ModFixer", withExtension: "pak"))
        let data = try BaseLSPK(url: url)
        
        XCTAssertEqual(data.version, .v15)
        XCTAssertEqual(data.header.parts, 1)
        XCTAssertEqual(data.header.fileListOffset, 192)
        XCTAssertEqual(data.header.fileListSize, 90)
        
        let entry = try XCTUnwrap(data.entries.first)
        XCTAssertEqual(entry.name, "Mods/Gustav/Story/RawFiles/Goals/ForceRecompile.txt")
    }
    
    func testGoldWeightZero() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Gold Weight Zero", withExtension: "pak"))
        let data = try ModLSPK(url: url)
        
        XCTAssertEqual(data.version, .v18)
        XCTAssertEqual(data.header.parts, 1)
        XCTAssertEqual(data.header.fileListOffset, 1000)
        XCTAssertEqual(data.header.fileListSize, 113)
        
        let moduleInfo = try XCTUnwrap(data.meta.moduleInfo)
        let publishVersion = try XCTUnwrap(moduleInfo.publishVersion)
        XCTAssertEqual(publishVersion.uuid, "GOLDWEIG-HTZE-RO12-4444-deeeeeeeeeef")
        XCTAssertEqual(publishVersion.name, "Gold Weight Zero")
        XCTAssertEqual(publishVersion.folder, "Gold Weight Zero")
    }
}
