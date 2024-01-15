import GPIO

@main
struct gpiodetect {

    static func main() async throws {
        let paths = try GPIO.allChipPaths()
        for path in paths {
            print(path)
            let chip = try Chip(path: path)
            print("Chip initialized")
            let info = chip.info()
            print(info)
            for index in 0 ..< info.lines {
                let lineInfo = chip.lineInfo(offset: index)
                print(lineInfo)
            }
            print("")
        }
    }
}