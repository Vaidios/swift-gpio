#if os(Linux)
import CGPIO
import Glibc
#endif
import Foundation
import SystemPackage

public final class Chip {

    public struct Info {
        public let name: String
        public let label: String
        public let lines: UInt32
    }

    private let path: String
    private let fileDescriptor: FileDescriptor

    public init(path: String) throws {
        if path.isEmpty {
            throw GPIOError.emptyPath
        }

        let gpio = GPIO()
        if !gpio.checkIfGpioChipDevice(path: path) {
            throw GPIOError.notGPIOChipDevice
        }

        self.fileDescriptor = try FileDescriptor.open(path, .readWrite, options: [.closeOnExec], permissions: nil, retryOnInterrupt: false)
        self.path = path
    }

    deinit {
        do {
            try fileDescriptor.close()
        } catch {
            print(error)
        }
    }

    public func info() -> Info {

        var info: gpiochip_info = .init()

        let ret = gpio_get_chip_info_ioctl(fileDescriptor.rawValue, &info)
        guard ret == 0 else {
            fatalError()
        }

        guard let cName = gpiod_chip_info_get_name(&info),
              let cLabel = gpiod_chip_info_get_label(&info) else {
            fatalError()
        }
        let name = String(cString: cName)
        let label = String(cString: cLabel)
        let lines = info.lines
        
        return Info(
            name: name,
            label: label,
            lines: lines
        )
    }

    public struct LineInfo {
        public let name: String
        public let consumer: String
        public let offset: UInt32
        public let numberOfAttributes: UInt32
    }

    public func lineInfo(offset: UInt32) -> LineInfo {
        var info: gpio_v2_line_info = .init()
        let watch = false

        info.offset = offset

        let ret = gpiod_chip_get_line_info_ioctl(fileDescriptor.rawValue, &info)
        if ret != 0 {
            let errsv = errno
            // Handling the error
            if let errorMessage = String(validatingUTF8: strerror(errsv)) {
                print("ioctl failed: \(errorMessage)")
            }
            fatalError()
        }

        guard let cName = gpiod_line_info_get_name(&info) else {
            fatalError()
        }

        let encoding: String.Encoding = .ascii
        var consumer: String = ""
        if let cConsumer = gpiod_line_info_get_consumer(&info) {
            var index = 0
            while cConsumer[index] != 0 {
                let char = cConsumer[index]
                // print("Character: \(char) ASCII Value: \(Int(char))")
                index += 1
            }
            consumer = String(cString: cConsumer, encoding: encoding) ?? "Encoding failure \(encoding)"
        }

        let name = String(cString: cName)
        
        

        return LineInfo(
            name: name,
            consumer: consumer,
            offset: info.offset,
            numberOfAttributes: info.num_attrs
        )
    }

    public func requestLines(lineBulkConfiguration: Line.BulkConfiguration, requestConfiguration: RequestConfiguration) -> Line.Request? {
        var request: gpio_v2_line_request = .init()
        request.event_buffer_size = 0

        requestConfiguration.toUAPI(request: &request)
        lineBulkConfiguration.toUAPI(request: &request)

        let chipInfo = self.info()

        let ret = gpio_v2_get_line_ioctl(fileDescriptor.rawValue, &request)

        return Line.Request.fromUAPI(request: &request, chipName: chipInfo.name)
    }
}

extension Line.Request {

    static func fromUAPI(request: inout gpio_v2_line_request, chipName: String) -> Self? {
        let numLines = Int(request.num_lines)
        
        // Ensure the chip name is not empty
        guard !chipName.isEmpty else { return nil }

        var offsets = [UInt32]()
        // Assuming gpio_v2_line_request.offsets is an array of integers
        for i in 0..<numLines {
            offsets.append(gpio_v2_line_request_get_offset(&request, UInt32(i)))
        }

        return Self(
            chipName: chipName,
            fileDescriptor: FileDescriptor(rawValue: request.fd),
            numLines: numLines,
            offsets: offsets
        )
    }
}

extension Line.BulkConfiguration {

    private func setOffsets(request: inout gpio_v2_line_request) {
        request.num_lines = UInt32(self.configs.count)
        for (index, lineConfig) in self.configs.enumerated() {
            gpio_v2_line_request_set_offset(&request, index, lineConfig.offset)
        }
    }

    private func setOutputValues(request: inout gpio_v2_line_request, attributeIndex: inout UInt32) {
        var attribute: gpio_v2_line_config_attribute = .init()

        attribute = gpio_v2_line_request_get_attribute(&request, &attributeIndex)
        attribute.attr.id = GPIO_V2_LINE_ATTR_ID_OUTPUT_VALUES.rawValue
        attribute.attr.values = 0
        attribute.mask = 0
    }

    func setDebounceValues(request: inout gpio_v2_line_request, attributeIndex: inout UInt32) {
        var attribute: gpio_v2_line_config_attribute = .init()
        var done: UInt64 = 0
        var mask: UInt64 = 0

        attribute = gpio_v2_line_request_get_attribute(&request, &attributeIndex)

        done = 0 // void gpiod_line_mask_zero(uint64_t *mask)

        for (index, lineConfig) in self.configs.enumerated() {
            if Line.maskTestBit(mask: &done, nr: UInt(index)) {
                continue
            }

            Line.maskSetBit(mask: &done, nr: UInt(index))
            mask = 0


            let periodI = lineConfig.settings.debouncePeriod
            if periodI == 0 {
                continue
            }

            if attributeIndex == GPIO_V2_LINE_NUM_ATTRS_MAX {
                fatalError("Attributes too long")
            }

            attribute = gpio_v2_line_request_get_attribute(&request, &attributeIndex)

            attribute.attr.id = GPIO_V2_LINE_ATTR_ID_DEBOUNCE.rawValue
            attribute.attr.debounce_period_us = periodI
            Line.maskSetBit(mask: &mask, nr: UInt(index))

            for (j, lineConfig) in self.configs.enumerated() {
                let periodJ = lineConfig.settings.debouncePeriod
                if periodI == periodJ {
                    Line.maskSetBit(mask: &mask, nr: UInt(j))
                    Line.maskSetBit(mask: &done, nr: UInt(j))
                }
            }

            attribute.mask = mask
        }
    }

    func toUAPI(request: inout gpio_v2_line_request) {
        var attributeIndex: UInt32 = 0
        setOffsets(request: &request)
        setOutputValues(request: &request, attributeIndex: &attributeIndex)

        setDebounceValues(request: &request, attributeIndex: &attributeIndex)

        request.config.num_attrs = attributeIndex

    }
}
