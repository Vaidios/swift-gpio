#if os(Linux)
import CGPIO
import Glibc
#endif
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

// struct gpio_v2_line_info {
// 	char name[GPIO_MAX_NAME_SIZE];
// 	char consumer[GPIO_MAX_NAME_SIZE];
// 	__u32 offset;
// 	__u32 num_attrs;
// 	__aligned_u64 flags;
// 	struct gpio_v2_line_attribute attrs[GPIO_V2_LINE_NUM_ATTRS_MAX];
// 	/* Space reserved for future use. */
// 	__u32 padding[4];
// };
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

        gpiod_chip_get_line_info_ioctl(fileDescriptor.rawValue, &info)

        guard let cName = gpiod_line_info_get_name(&info),
        let cConsumer = gpiod_line_info_get_consumer(&info) else {
            fatalError()
        }

        let name = String(cString: cName)
        let consumer = String(cString: cConsumer)

        return LineInfo(
            name: name,
            consumer: consumer,
            offset: info.offset,
            numberOfAttributes: info.num_attrs
        )
    }

    public func requestLines(lineBulkConfiguration: Line.BulkConfiguration, requestConfiguration: RequestConfiguration) {
        var request: gpio_v2_line_request = .init()
        request.event_buffer_size = 0

        requestConfiguration.toUAPI(request: &request)
        lineBulkConfiguration.toUAPI(request: &request)

//         static void set_offsets(struct gpiod_line_config *config,
// 			struct gpio_v2_line_request *uapi_cfg)
// {
// 	size_t i;

// 	uapi_cfg->num_lines = config->num_configs;

// 	for (i = 0; i < config->num_configs; i++)
// 		uapi_cfg->offsets[i] = config->line_configs[i].offset;
// }

//         int gpiod_line_config_to_uapi(struct gpiod_line_config *config,
// 			      struct gpio_v2_line_request *uapi_cfg)
// {
// 	unsigned int attr_idx = 0;
// 	int ret;

// 	set_offsets(config, uapi_cfg);
// 	set_output_values(config, uapi_cfg, &attr_idx);

// 	ret = set_debounce_periods(config, &uapi_cfg->config, &attr_idx);
// 	if (ret)
// 		return -1;

// 	ret = set_flags(config, &uapi_cfg->config, &attr_idx);
// 	if (ret)
// 		return -1;

// 	uapi_cfg->config.num_attrs = attr_idx;

// 	return 0;
// }
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

    func toUAPI(request: inout gpio_v2_line_request) {
        var attributeIndex: UInt32 = 0
        setOffsets(request: &request)
        setOutputValues(request: &request, attributeIndex: &attributeIndex)
    }


}
