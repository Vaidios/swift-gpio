import CGPIO

public struct RequestConfiguration {
    public let consumer: String
    public let eventBufferSize: UInt32

    public init(consumer: String, eventBufferSize: UInt32) {
        self.consumer = consumer
        self.eventBufferSize = eventBufferSize
    }

    func toUAPI(request: inout gpio_v2_line_request) {
        var configConsumer = consumer.cString(using: .ascii)
        print("Settings consumer \(configConsumer)")
        gpio_v2_line_request_set_consumer(&request, &configConsumer)
        request.event_buffer_size = self.eventBufferSize
    }
}

public struct LineRequest {

    final class GetValue {

    }

    func getValuesSubset(
        offsets: Set<UInt>
    ) {
        var uapiValues: gpio_v2_line_values = .init()

        if offsets.isEmpty {
            fatalError()
        }

        var mask: UInt64 = 0

        uapiValues.bits = 0

        for offset in offsets {
            let bit = offsetToBit(offset: offset)
            setBit(mask: &mask, nr: bit)
        }

        uapiValues.mask = mask

        let ret = gpio_line_get_values_ioctl(0, &uapiValues)

        if ret < 0 {
            fatalError()
        }

        let bits = uapiValues.bits

    }

    func offsetToBit(offset: UInt)-> UInt {
        return 0
    }

    func setBit(mask: inout UInt64, nr: UInt) {
        mask |= (1 << nr)
    }
}