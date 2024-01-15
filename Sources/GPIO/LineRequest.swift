import CGPIO

struct LineRequest {

    final class GetValue {

    }

    func getValuesSubset(
        offsets: Set<UInt>,
        values: [Bool]
    ) {
        var uapiValues: gpio_v2_line_values = .init()

        if offsets.isEmpty || values.isEmpty {
            fatalError()
        }

        uapiValues.bits = 0

        for offset in offsets {

        }
    }
}