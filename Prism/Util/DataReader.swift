//
//  DataReader.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2017/09/23.
//  Copyright © 2017 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class DataReader {
    let data: Data
    var offset: Int
    var endian: ByteOrder = .bigEndian

    init(_ data: Data) {
        self.data   = data
        self.offset = 0
    }

    func advance(_ n: Int) {
        offset += n
    }

    var length: Int { get { return data.count - offset } }

    func get_u8() -> UInt8 {
        return data[offset]
    }

    func get16be(at: Int) -> UInt16 {
        return UInt16(data[offset + at]) * 256 + UInt16(data[offset + at + 1])
    }

    func readdata(_ len: Int) -> Data {
        let d = data.subdata(in: offset..<offset+len)
        offset += len
        return d
    }

    func read_u8() -> UInt8 {
        let val = data[offset]
        offset += 1
        return val
    }

    func read_u16() -> UInt16 {
        let val = read_u16be()
        if endian == .bigEndian {
            return val
        } else {
            return val.byteSwapped
        }
    }

    func read_s32() -> Int32 {
        let val = read_s32be()
        if endian == .bigEndian {
            return val
        } else {
            return val.byteSwapped
        }
    }

    func read_u32() -> UInt32 {
        let val = read_u32be()
        if endian == .bigEndian {
            return val
        } else {
            return val.byteSwapped
        }
    }

    func read_u16be() -> UInt16 {
        let val = UInt16(data[offset]) * 256 + UInt16(data[offset + 1])
        offset += 2
        return val
    }

    func u16endian() -> UInt16 {
        if (endian == .bigEndian) {
            return read_u16be()
        } else {
            return read_u16be().littleEndian
        }
    }

    func read_s32be() -> Int32 {
        var val = Int32(data[offset]) * 256 * 256 * 256
        val += Int32(data[offset + 1]) * 256 * 256
        val += Int32(data[offset + 2]) * 256
        val += Int32(data[offset + 3])
        offset += 4
        return val
    }

    func u32() -> UInt32 {
        var val = UInt32(data[offset]) * 256 * 256 * 256
        val += UInt32(data[offset + 1]) * 256 * 256
        val += UInt32(data[offset + 2]) * 256
        val += UInt32(data[offset + 3])
        offset += 4
        return val
    }

    func read_u32be() -> UInt32 {
        return u32()
    }

    func skip8() {
        advance(1)
    }

    func skip16() {
        advance(2)
    }

    func skip32() {
        advance(4)
    }

    func u32endian() -> UInt32 {
        if (endian == .bigEndian) {
            return read_u32be()
        } else {
            return u32le()
        }
    }

    func u32le() -> UInt32 {
        return u32().byteSwapped
    }
}
