//
//  Ethernet.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/26/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

// Link Layer Protocol of DLT_EN10B

class Ethernet : BaseProtocol {
    override var name: String { get { return "Ethernet" } }

    var ethertype = 0
    
    var src: [UInt8] {
        get {
            var bytes = [UInt8]()
            let ptr = UnsafePointer<UInt8>(data.bytes) + 6
            for i in 0..<6 {
               bytes.append((ptr + i).memory)
            }
            return bytes
        }
    }

    override class func parse(context: ParseContext) -> Protocol {
        let p = Ethernet(context)
        
        let reader = context.reader
        reader.advance(12)

        switch (reader.read_u16be()) {
        case 0x0800:
            context.parser = IPv4.parse
        case 0x86dd:
            context.parser = IPv6.parse
        default:
            break
        }
        return p
    }
}
