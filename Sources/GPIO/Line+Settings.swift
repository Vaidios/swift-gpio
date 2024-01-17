extension Line {

    public struct Settings {

        public let direction: Direction
        public let edge: Edge
        public let drive: Drive
        public let bias: Bias
        public let activeLow: Bool
        public let eventClock: EventClock
        public let debouncePeriod: Double
        public let outputValue: Value

        public init(
            direction: Direction,
            edge: Edge,
            drive: Drive,
            bias: Bias,
            activeLow: Bool,
            eventClock: EventClock,
            debouncePeriod: Double,
            outputValue: Value
        ) { 
            self.direction = direction
            self.edge = edge
            self.drive = drive
            self.bias = bias
            self.activeLow = activeLow
            self.eventClock = eventClock
            self.debouncePeriod = debouncePeriod
            self.outputValue = outputValue
        }
    }

    public enum Direction {
        case asIs
        case input
        case output
    }

    public enum Edge {
        case none
        case rising
        case falling
        case both
    }

    public enum Drive {
        case pushPull
        case openDrain
        case openSource
    }

    public enum Bias {
        case asIs
        case unknown
        case disabled
        case pullUp
        case pullDown
    }

    public enum EventClock {
        case monotonic
        case realtime
        case hte
    }

    public enum Value {
        case error
        case inactive
        case active
    }
}