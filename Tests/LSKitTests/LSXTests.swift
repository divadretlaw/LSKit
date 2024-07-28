import XCTest
@testable import LSKit
import Compression

final class LSXTests: XCTestCase {
    func testModSettings() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "modsettings", withExtension: "lsx"))
        let lsx = try XCTUnwrap(LSX(url: url))
        
        XCTAssertEqual(lsx.version, LSXVersion(major: "4", minor: "6", revision: "0", build: "900"))
        let moduleSettings = try XCTUnwrap(lsx.regions.first)
        XCTAssertEqual(moduleSettings.id, "ModuleSettings")
        let rootNode = try XCTUnwrap(moduleSettings.nodes.first)
        XCTAssertEqual(rootNode.id, "root")
        
        let modOrderNode = try XCTUnwrap(rootNode.children.first { $0.id == "ModOrder" })
        XCTAssertEqual(modOrderNode.id, "ModOrder")
        let firstModOrder = try XCTUnwrap(modOrderNode.children.first)
        XCTAssertEqual(firstModOrder.attributes.first { $0.id == "UUID" }?.value, "28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8")
        
        let modsNode = try XCTUnwrap(rootNode.children.first { $0.id == "Mods" })
        XCTAssertEqual(modsNode.id, "Mods")
        let firstMod = try XCTUnwrap(modsNode.children.first)
        XCTAssertEqual(firstMod.attributes.first { $0.id == "UUID" }?.value, "28ac9ce2-2aba-8cda-b3b5-6e922f71b6b8")
        XCTAssertEqual(firstMod.attributes.first { $0.id == "Name" }?.value, "GustavDev")
        XCTAssertEqual(firstMod.attributes.first { $0.id == "Folder" }?.value, "GustavDev")
        
        print(lsx.xml())
    }
    
    func testMeta() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "meta", withExtension: "lsx"))
        let lsx = try XCTUnwrap(LSX(url: url))
        
        XCTAssertEqual(lsx.version, LSXVersion(major: "4", minor: "0", revision: "9", build: "331"))
        let config = try XCTUnwrap(lsx.regions.first)
        XCTAssertEqual(config.id, "Config")
        let rootNode = try XCTUnwrap(config.nodes.first)
        XCTAssertEqual(rootNode.id, "root")
    }
}
