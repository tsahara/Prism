//
//  IPv6.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class IPv6 : BaseProtocol {
    override var name: String { get { return "IPv6" } }
    override var isNetworkProtocol: Bool { get { return true } }

    override class func parse(_ context: ParseContext) -> Protocol {
        let p = IPv6(context)

        let reader = context.reader
        if (reader.length < 40) {
            p.broken = true
            return p
        }
        p.header_length = 40
        
        // version:4
        // traffic-class:8
        // Flow Label: 20
        // Payload Length: 16
        // Next Header: 8
        // Hop Limit: 8
        // Source Address: 128
        // Destination Address: 128
       
        reader.u32()
        let len = Int(reader.read_u16be())
        if (reader.length < 40 + len) {
            p.broken = true
        }
        
        let nxthdr = reader.read_u8()
        switch nxthdr {
        case 6:
            context.parser = TCP.parse
        case 17:
            context.parser = UDP.parse
        case 58:
            context.parser = ICMP6.parse
        default:
            context.parser = UnknownProtocol.parse
        }
        reader.read_u8()
        reader.readdata(16)
        reader.readdata(16)
        return p
    }

    var dst: IPv6Address? {
        get {
            guard header_length >= 40 else {
                return nil
            }
            return IPv6Address(data: data, offset: self.offset + 24)
        }
    }

    var src: IPv6Address? {
        get {
            guard header_length >= 32 else {
                return nil
            }
            return IPv6Address(data: data, offset: self.offset + 8)
        }
    }
}
