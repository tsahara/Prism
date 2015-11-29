//
//  NSDataReader.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/10/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class NSDataReader {
    let data: NSData
    var offset: Int
    var endian: ByteOrder = .BigEndian
    
    init(_ data: NSData) {
        self.data   = data
        self.offset = 0
    }

    func advance(n: Int) {
        offset += n
    }
    
    var length: Int { get { return data.length - offset } }
    
    func get_u8() -> UInt8 {
        return UnsafePointer<UInt8>(data.bytes + offset).memory
    }
   
    func readdata(len: Int) -> NSData {
        let d = NSData(bytes: data.bytes + offset, length: len)
        offset += len
        return d
    }
    
    func read_u8() -> UInt8 {
        let val = UnsafePointer<UInt8>(data.bytes + offset).memory
        offset += 1
        return val
    }
    
    func read_u16be() -> UInt16 {
        let val = UnsafePointer<UInt16>(data.bytes + offset).memory.bigEndian
        offset += 2
        return val
    }

    func u16endian() -> UInt16 {
        if (endian == .BigEndian) {
            return read_u16be()
        } else {
            return read_u16be().littleEndian
        }
    }

    func u32() -> UInt32 {
        let val = UnsafePointer<UInt32>(data.bytes + offset).memory.bigEndian
        offset += 4
        return val
    }
    
    func read_u32be() -> UInt32 {
        return u32()
    }

    func u32endian() -> UInt32 {
        if (endian == .BigEndian) {
            return read_u32be()
        } else {
            return u32le()
        }
    }
   
    func u32le() -> UInt32 {
        return u32().byteSwapped
    }
}
