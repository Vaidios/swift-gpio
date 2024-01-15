import Foundation
import SystemPackage
import CGPIO
import Glibc

struct Chip {
    let fd: Int
    let path: String
}

public struct GPIO {

    public static func run() {
        let gpio = GPIO()

        try? gpio.allChipPaths()
        // gpio.gpiodInfoEventRead(fileDescriptor: )
        
        // SystemPackage.FileDescriptor
    }

    // func gpiodInfoEventRead(fileDescriptor: FileDescriptor) {
    //     let uapi_evt = CGPIO.gpio_v2_line_info_changed
    //     fileDescriptor.read(into: &uapi_evt)
    // }

    // func gpiodChipOpen(path: String) {

    // }

    func allChipPaths() throws -> [String] {
        let fileManager = FileManager.default
        let devDirectory = "/dev/"
        
        guard let directoryEnumerator = fileManager.enumerator(atPath: devDirectory) else {
            throw NSError(domain: "Unable to scan /dev directory", code: 1)
        }

        var paths: [String] = []

        for case let path as String in directoryEnumerator {
            if chipDirFilter(path: path) {
                paths.append(devDirectory + path)
            }
        }

        return paths
    }

    func chipDirFilter(path: String) -> Bool {
        let fullPath = "/dev/" + path

        // Check if the file exists and is not a symbolic link
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir),
            !isDir.boolValue else {
            return false
        }

        // Replace this with your logic to determine if the file is a GPIO chip device
        // This might involve checking file properties, contents, or a custom system call.
        let isGpioChipDevice = checkIfGpioChipDevice(path: fullPath)

        return isGpioChipDevice
    }

    private func checkIfGpioChipDevice(path: String) -> Bool {
        return gpiodCheckGpiochipDevice(path: path, setErrno: false)
    }

    func gpiodCheckGpiochipDevice(path: String, setErrno: Bool) -> Bool {
        guard !path.isEmpty else {
            if setErrno { errno = EINVAL }
            return false
        }

        var isLink: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isLink),
            let fileAttributes = try? FileManager.default.attributesOfItem(atPath: path),
            let fileType = fileAttributes[.type] as? FileAttributeType else {
            return false
        }

        let realPath = isLink.boolValue ? (try? FileManager.default.destinationOfSymbolicLink(atPath: path)) ?? path : path

        guard let deviceAttributes = try? FileManager.default.attributesOfItem(atPath: realPath),
            let deviceType = deviceAttributes[.type] as? FileAttributeType,
            deviceType == .typeCharacterSpecial else {
            if setErrno { errno = ENOTTY }
            return false
        }

        // Verify if the device is associated with the GPIO subsystem
        // This step is system-specific and might require additional system-level calls or bridges
        let isGpioSubsystem = checkIfGpioSubsystem(devicePath: realPath)

        if setErrno && !isGpioSubsystem { errno = ENODEV }
        return isGpioSubsystem
    }

     public func rawMode(stat: stat) -> UInt32 { return stat.st_mode }

    private func checkIfGpioSubsystem(devicePath: String) -> Bool {
        var statbuf = stat()
        let rv = lstat(devicePath, &statbuf)
        if rv == -1 {
            fatalError()
        }

        let isSymlink = (rawMode(stat: statbuf) & S_IFMT) == S_IFLNK

        let cMajor = dev_major(statbuf.st_rdev)
        let cMinor = dev_minor(statbuf.st_rdev)

        let createDevicePath = createDevicePath(majorNumber: cMajor, minorNumber: cMinor)
        guard let sysfsp = try? realpath(createDevicePath) else {
            // print("Could not get real path of devicePath")
            return false
        }
        let sysfspString = String(cString: sysfsp)
        // print("Did get a realpath!")


        guard sysfspString == "/sys/bus/gpio" else {
            return false
        }
        print("Found GPIO device!")
        print(devicePath)
        print(createDevicePath)
        print(sysfspString)
        
        // print(devicePath)
        // Implement the logic to check if the device is part of the GPIO subsystem.
        // This requires system-specific implementation.
        return true // Placeholder implementation
    }

    func createDevicePath(majorNumber: Int32, minorNumber: Int32) -> String {
        let devicePath = "/sys/dev/char/\(majorNumber):\(minorNumber)/subsystem"

        return devicePath
    }
    
}

enum SystemError: Error {
    case realpath(Int32, String)
}


public func realpath(_ path: String) throws -> String {
    let rv = realpath(path, nil)
    guard let rv else { throw SystemError.realpath(errno, path) }
    defer { free(rv) }
    let rvv = String(cString: rv)
    return rvv
}

func major(_ x: dev_t) -> UInt {
    return (x >> 24) & 0xff
}

func minor(_ x: dev_t) -> UInt {
    return x & 0xffffff
}