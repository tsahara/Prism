//
//  ParseContext.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/14/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

enum ByteOrder {
    case bigEndian, littleEndian
    
    static func host() -> ByteOrder {
        if CFByteOrderGetCurrent() == Int(CFByteOrderLittleEndian.rawValue) {
            return .littleEndian
        } else {
            return .bigEndian
        }
    }
}

typealias ParseClosure = ((ParseContext) -> Protocol)?

@objc class ParseContext : NSObject {
    let reader: DataReader
    let endian: ByteOrder
    
    var parser: ParseClosure
    
    init(_ data: Data, endian: ByteOrder, parser: ParseClosure) {
        self.reader = DataReader(data)
        self.endian = endian
        self.parser = parser
    }
}
