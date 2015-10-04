//
//  Null.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 10/3/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class NullProtocol : BaseProtocol {
    override var name: String { get { return "Null" } }
    
    override class func parse(context: ParseContext) -> Protocol {
        let p = NullProtocol(context)
        
        let reader = context.reader
        let firstbyte = reader.get_u8()
        print("data=\(reader.data)")
        if ((firstbyte & 0xf0) == 0x40) {
            context.parser = IPv4.parse
        } else if ((firstbyte & 0xf0) == 0x60) {
            context.parser = IPv6.parse
        }
        return p
    }
}
