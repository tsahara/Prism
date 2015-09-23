//
//  IPv4.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/23/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class IPv4 : BaseProtocol {
    override var name: String { get { return "IPv4" } }
    override var isNetworkProtocol: Bool { get { return true } }
    
    override class func parse(context: ParseContext) -> Protocol {
        let p = IPv4(context)
        
        let r = context.reader
        if (r.length < 20) {
            p.broken = true
            return p
        }
        p.header_length = 20
        
        r.read_u8()  // version, ihl
        r.read_u8()  // tos
        let total_length = r.read_u16be()
        r.read_u16be() // id
        r.read_u16be() // fragment+offset
        r.read_u8()    // ttl
        let proto = r.read_u8()
        r.read_u16be() // cksum
        r.read_u32be()
        r.read_u32be()

        context.parser = nil
        return p
    }
}
