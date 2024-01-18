import GPIO

@main
struct gpioget {

    static func main() async throws {

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
        let configuration = RequestConfiguration(consumer: "gpioget", eventBufferSize: 1)
        let lineConfiguration = Line.Configuration(offset: 0, settings: settings)
        let bulkConfiguration = Line.BulkConfiguration(configs: [lineConfiguration], values: [.active])

        for path in try Chip.allChipPaths() {
            let chip = try Chip(path: path)

            guard let request = chip.requestLines(lineBulkConfiguration: bulkConfiguration, requestConfiguration: configuration) else { return }
            print(request.chipName)
            print(request.numLines)
            print(request.offsets)
            let info = chip.info()
            print(info)
            for index in 0 ..< info.lines {
                let lineInfo = chip.lineInfo(offset: index)
                if index == 0 {
                    print(lineInfo)
                }
                
            }
            print("")
        }
    }
}