import SystemPackage

extension Line {
    public struct Request {
        public let chipName: String
        public let fileDescriptor: FileDescriptor
        public let numLines: Int
        public let offsets: [UInt32]
    }
}