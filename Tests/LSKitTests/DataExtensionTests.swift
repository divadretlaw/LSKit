import XCTest
@testable import LSKit

final class DataExtensionTests: XCTestCase {
    func testChunked() {
        let data = Data([0x01, 0x02, 0x03, 0x04, 0x05])
        XCTAssertEqual(data.chunked(size: 0).count, 1)

        XCTAssertEqual(data.chunked(size: 1).count, 5)
        XCTAssertEqual(data.chunked(size: 2).count, 3)
        XCTAssertEqual(data.chunked(size: 3).count, 2)
        XCTAssertEqual(data.chunked(size: 4).count, 2)
        XCTAssertEqual(data.chunked(size: 5).count, 1)
        XCTAssertEqual(data.chunked(size: 6).count, 1)
    }
}
