extension Line {

    public struct Configuration {
        let offset: UInt32
        let settings: Settings
    }

    public struct BulkConfiguration {
        let configs: [Configuration]
        let values: [Value]
    }
}