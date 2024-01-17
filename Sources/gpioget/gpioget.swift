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

    }
}