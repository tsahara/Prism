//
//  NSDataReader.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/10/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
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
