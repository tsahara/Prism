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

    override class func parse(context: ParseContext) -> Protocol {
        let p = Ethernet(context)
        
        let reader = context.reader
        reader.advance(12)
        
        switch (reader.read_u16be()) {
        case 0x0800:
            context.parser = IPv4.parse
        case 0x8644:
            context.parser = IPv6.parse
        default:
            break
        }
        return p
    }
}
