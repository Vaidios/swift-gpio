func gpiodLineMaskSetBit(mask: inout UInt64, nr: UInt) {
    mask |= (1 << nr)
}