public enum Line {

    static func maskTestBit(mask: inout UInt64, nr: UInt) -> Bool {
        return mask & (1 << nr) != 0
    }

    static func maskSetBit(mask: inout UInt64, nr: UInt) {
        mask |= (1 << nr)
    }
 }