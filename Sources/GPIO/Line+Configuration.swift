extension Line {

    public struct Configuration {
        let offset: UInt32
        let settings: Settings

        public init(offset: UInt32, settings: Settings) {
            self.offset = offset
            self.settings = settings
        }
    }

    public struct BulkConfiguration {

        let configs: [Configuration]
        let values: [Value]

        public init(configs: [Configuration], values: [Value]) {
            self.configs = configs
            self.values = values
        }
    }
}