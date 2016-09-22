//
//  Ethernet.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/26/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

// Link Layer Protocol of DLT_EN10B

// Destination MAC Address : 6 octets
// Source MAC Address      : 6 octets
// Ethertype               : 2 octets

class Ethernet : BaseProtocol {
    override var name: String { get { return "Ethernet" } }
    
    var dst: [UInt8] {
        get {
            var bytes = [UInt8]()
            let ptr = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
            for i in 0..<6 {
                bytes.append((ptr + i).pointee)
            }
            return bytes
        }
    }
    
    var src: [UInt8] {
        get {
            var bytes = [UInt8]()
            let ptr = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) + 6
            for i in 0..<6 {
               bytes.append((ptr + i).pointee)
            }
            return bytes
        }
    }

    override class func parse(_ context: ParseContext) -> Protocol {
        let p = Ethernet(context)

        let reader = context.reader

        if reader.length >= 6 {
            let f = MacAddressField(reader: reader, length: 6, name: "Destination MAC Address")
            p.fields.append(f)
        }
        reader.advance(6)

        if reader.length >= 6 {
            let f = MacAddressField(reader: reader, length: 6, name: "Source MAC Address")
            p.fields.append(f)
        }
        reader.advance(6)

        p.fields.append(ProtocolField(reader: reader, length: 2, name: "Ethertype"))
        let type = reader.read_u16be()
        
        switch (type) {
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
