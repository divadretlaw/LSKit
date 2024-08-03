import XCTest
@testable import LSKit
import BinaryUtils

final class JSONTests: XCTestCase {
    func testModInfoDecode() throws {
        let json = """
        {
          "Mods": [
            {
              "Author": "divadretlaw",
              "Name": "TestMod",
              "Folder": "TestMod",
              "Version": "1",
              "Description": "A test mod",
              "UUID": "b5d3669b-df50-4884-8b07-0eb795ed3b96",
              "Created": "2024-07-28T12:00:00.1234567+01:00",
              "Dependencies": [],
              "Group": "d5af0305-973e-4e97-b3af-074e4928c1d0"
            }
          ],
          "MD5": "09f7e02f1290be211da707a266f153b3"
        }
        """
        let data = Data(json.utf8)
        let modInfo = try JSONDecoder().decode(ModInfo.self, from: data)
        XCTAssertEqual(modInfo.mods.count, 1)
        XCTAssertEqual(modInfo.md5, MD5(md5String: "09f7e02f1290be211da707a266f153b3"))
    }

    func testModInfoEncode() throws {
        let md5 = try XCTUnwrap(MD5(md5String: "09f7e02f1290be211da707a266f153b3"))
        let mod = ModInfo.Mod(uuid: UUID(), name: "TestMod", description: "A test mod", folder: "TestMod", version: "1", author: "divadretlaw", created: .now, group: UUID())
        let modInfo = ModInfo(mods: [mod], md5: md5)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(modInfo)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        print(json)
    }
}
