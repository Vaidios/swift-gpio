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

    func testGpiodLineRequest() throws {
                let settings = Line.Settings(
            direction: .output, 
            edge: .falling, 
            drive: .openDrain, 
            bias: .disabled, 
            activeLow: true, 
            eventClock: .realtime, 
            debouncePeriod: 2, 
            outputValue: .active
        )
        let consumer = "test"
        let configuration = RequestConfiguration(consumer: consumer, eventBufferSize: 1)
        let lineConfiguration = Line.Configuration(offset: 0, settings: settings)
        let bulkConfiguration = Line.BulkConfiguration(configs: [lineConfiguration], values: [.active])

        for path in try Chip.allChipPaths() {
            let chip = try Chip(path: path)

            guard let request = chip.requestLines(lineBulkConfiguration: bulkConfiguration, requestConfiguration: configuration) else { return }
            let info = chip.info()
            for index in 0 ..< info.lines {
                if index == 0 {
                    let lineInfo = chip.lineInfo(offset: index)
                    XCTAssertEqual(lineInfo.consumer, consumer)
                }
            }
        }
    }
}
