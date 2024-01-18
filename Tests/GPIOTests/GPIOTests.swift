import XCTest
@testable import GPIO

final class GPIOTests: XCTestCase {

    func testGpiodLineMaskTestBit() {
        var mask: UInt64 = 0b1010 // Example mask with some bits set
        XCTAssertTrue(Line.maskTestBit(mask: &mask, nr: 1), "Bit 1 should be set")
        XCTAssertFalse(Line.maskTestBit(mask: &mask, nr: 2), "Bit 2 should not be set")
        // Add more test cases as needed
    }

    func testGpiodLineMaskSetBit() {
        var mask: UInt64 = 0

        Line.maskSetBit(mask: &mask, nr: 1)
        XCTAssertEqual(mask, 0b10, "Bit 1 should be set")

        Line.maskSetBit(mask: &mask, nr: 3)
        XCTAssertEqual(mask, 0b1010, "Bits 1 and 3 should be set")
        // Add more test cases as needed
    }
}
