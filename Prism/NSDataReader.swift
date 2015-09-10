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
    
    init(_ data: NSData) {
        self.data   = data
        self.offset = 0
    }
    
    func advance(n: Int) {
        offset += n
    }
    
    func readdata(len: Int) -> NSData {
        let d = NSData(bytes: data.bytes + offset, length: len)
        offset += len
        return d
    }
    
    func u32() -> UInt32 {
        let val = UnsafePointer<UInt32>(data.bytes + offset).memory
        offset += 4
        return val
    }
}
