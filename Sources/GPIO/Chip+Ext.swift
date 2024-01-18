import Foundation

extension Chip {
    public static func allChipPaths() throws -> [String] {
        let gpio = GPIO()
        let fileManager = FileManager.default
        let devDirectory = "/dev/"
        
        guard let directoryEnumerator = fileManager.enumerator(atPath: devDirectory) else {
            throw NSError(domain: "Unable to scan /dev directory", code: 1)
        }

        var paths: [String] = []

        for case let path as String in directoryEnumerator {
            if gpio.chipDirFilter(path: path) {
                paths.append(devDirectory + path)
            }
        }

        return paths
    }
}