//
//  Loopback.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/13/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

// Link Layer Protocol of DLT_NULL

class LoopbackProtocol : BaseProtocol {
    override var name: String { get { return "Loopback" } }

    var af = 0
    
    override class func parse(context: ParseContext) -> Protocol {
        let p = LoopbackProtocol(context)

        let reader = context.reader
        if (context.endian == .LittleEndian) {
            p.af = Int(reader.u32le())
        } else {
            p.af = Int(reader.u32be())
        }

        switch (p.af) {
        case 30:
            context.parser = IPv6.parse
        default:
            break
        }
        return p
    }
}
