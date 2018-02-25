//
//  IPv4.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/23/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

// https://tools.ietf.org/html/rfc791#section-3.1
//
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |Version|  IHL  |Type of Service|          Total Length         |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |         Identification        |Flags|      Fragment Offset    |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |  Time to Live |    Protocol   |         Header Checksum       |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |                       Source Address                          |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |                    Destination Address                        |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
// |                    Options                    |    Padding    |
// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

class IPv4 : BaseProtocol {
    override var name: String { get { return "IPv4" } }
    override var isNetworkProtocol: Bool { get { return true } }
    
    override class func parse(_ context: ParseContext) -> Protocol {
        let p = IPv4(context)
        
        let r = context.reader
        if (r.length < 20) {
            p.broken = true
            return p
        }
        p.header_length = 20

        r.skip8()  // version, ihl
        r.skip8()  // tos
        r.skip16() // total_length
        r.skip16() // id
        r.skip16() // fragment+offset
        r.skip8()  // ttl
        let proto = r.read_u8()
        r.skip16() // cksum

        let f = IPv4AddressField(reader: r, length: 4, name: "Source IP Address")
        p.fields.append(f)
        r.advance(4)

        p.fields.append(IPv4AddressField(reader: r, length: 4, name: "Destination IP Address"))
        r.advance(4)
        
        switch proto {
        case 1:
            context.parser = ICMP.parse
        case 6:
            context.parser = TCP.parse
        case 17:
            context.parser = UDP.parse
        default:
            context.parser = UnknownProtocol.parse
        }
        return p
    }

    var src: IPv4Address? {
        get {
            guard header_length >= 16 else {
                return nil
            }
            return IPv4Address(data: data, offset: self.offset + 12)
        }
    }

    var dst: IPv4Address? {
        get {
            guard header_length >= 20 else {
                return nil
            }
            return IPv4Address(data: data, offset: self.offset + 16)
        }
    }
}
