//
//  ParseContext.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/14/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

enum ByteOrder {
    case BigEndian, LittleEndian
}

typealias ParseClosure = ((ParseContext) -> Protocol)?

class ParseContext {
    let reader: NSDataReader
    let endian: ByteOrder
    
    var parser: ParseClosure
    
    init(_ data: NSData, endian: ByteOrder, parser: ParseClosure) {
        self.reader = NSDataReader(data)
        self.endian = endian
        self.parser = parser
    }
}
