//
//  Packet.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 8/22/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class Packet {
    let timestamp: NSDate
    let original_length: Int
    let captured_length: Int
    let data: NSData
    
    var protocols: [Protocol] = []
    var layer3: Protocol? = nil
    var transport: Protocol? = nil
    
    init(timestamp: NSDate, original_length: Int, captured_length: Int, data: NSData) {
        self.timestamp = timestamp
        self.original_length = original_length
        self.captured_length = captured_length
        self.data = data
    }
    
    func parse(context: ParseContext) {
        var p: Protocol

        while (context.parser != nil) {
            let parser = context.parser!
            context.parser = nil
            p = parser(context)
            protocols.append(p)
        }
    }
    
    var proto: String {
        get {
            return protocols[protocols.count - 1].name
        }
    }

    var ipv4: IPv4? {
        get {
            if (protocols.count >= 2) {
                if let p = protocols[1] as? IPv4 {
                    return p
                }
            }
            return nil
        }
    }

    var ipv6: IPv6? {
        get {
            if (protocols.count >= 2) {
                if let p = protocols[1] as? IPv6 {
                    return p
                }
            }
            return nil
        }
    }

    var tcp: TCP? {
        get {
            if (protocols.count >= 3) {
                if let p = protocols[2] as? TCP {
                    return p
                }
            }
            return nil
        }
    }

    var udp: UDP? {
        get {
            if (protocols.count >= 3) {
                if let p = protocols[2] as? UDP {
                    return p
                }
            }
            return nil
        }
    }
    
    var src_string: String {
        get {
            if let p = protocols[0] as? Ethernet {
                    return String(format: "%02x:%02x:%02x:%02x:%02x:%02x", arguments: p.src.map {
                        byte in UInt(byte) })
            }
            return ""
        }
    }

    class func parseText(text: String) -> Packet? {
        var timestamp: NSDate?
        var buf = [UInt8](count: 2000, repeatedValue: 0)
        var idx = 0

        var time_t_now = time(nil)
        let tm_now = localtime(&time_t_now).memory

        let re_summary = try! NSRegularExpression(pattern: "^(\\d{2}):(\\d{2}):(\\d{2}\\.\\d+) ", options: [])
        let re_bytes = try! NSRegularExpression(pattern: "^\\s*0x(?:[0-9a-fA-F]{4}): ((?: [0-9a-fA-F]+)+)", options: [])
        
        NSString(string: text).enumerateLinesUsingBlock {
            line, _ in
            let nsline = line as NSString
            
            if let m = re_summary.firstMatchInString(line, options: [], range: NSRange(location: 0, length: line.characters.count)) {
                var tm = tm_now
                tm.tm_hour = Int32(Int(nsline.substringWithRange(m.rangeAtIndex(1)))!)
                tm.tm_min  = Int32(Int(nsline.substringWithRange(m.rangeAtIndex(2)))!)
                tm.tm_sec  = 0
                let sec = Double(nsline.substringWithRange(m.rangeAtIndex(3)))!
                timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(Double(mktime(&tm)) + sec))
            }
            
            if let m = re_bytes.firstMatchInString(line, options: [], range: NSRange(location: 0, length: line.characters.count)) {
                for s in nsline.substringWithRange(m.rangeAtIndex(1)).componentsSeparatedByString(" ") {
                    if s.characters.count == 4 {
                        let word = strtoul(s, nil, 16)
                        buf[idx]   = UInt8(word >> 8)
                        buf[idx+1] = UInt8(word & 0xff)
                        idx += 2
                    } else if s.characters.count == 2 {
                        let word = strtoul(s, nil, 16)
                        buf[idx] = UInt8(word & 0xff)
                        idx += 1
                    }
                }
                
            }
        }
        let data = NSData(bytes: buf, length: idx)
        if timestamp != nil {
            let pkt = Packet(timestamp: timestamp!, original_length: data.length, captured_length: data.length, data: data)
            let context = ParseContext(pkt.data, endian: .BigEndian, parser: NullProtocol.parse)
            pkt.parse(context)
            return pkt
        } else {
            return nil
        }
    }
}
