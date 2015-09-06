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
    
    init(timestamp: NSDate, original_length: Int, captured_length: Int, data: NSData) {
        self.timestamp = timestamp
        self.original_length = original_length
        self.captured_length = captured_length
        self.data = data
    }
    
    class func parseText(text: String) -> Packet? {
        var timestamp: NSDate?
        var buf = [UInt8](count: 2000, repeatedValue: 0)
        var idx = 0

        var now = time(nil)
        let tm_now = localtime(&now).memory

        let re_summary = NSRegularExpression(pattern: "^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d+) ", options: nil, error: nil)!
        let re_bytes = NSRegularExpression(pattern: "^ *0x(?:[0-9a-fA-F]{4}): ((?: [0-9a-fA-F]+)+)", options: nil, error: nil)!
        
        NSString(string: text).enumerateLinesUsingBlock {
            line, _ in
            let nsline = line as NSString

            if let m = re_summary.firstMatchInString(line, options: nil, range: NSRange(location: 0, length: count(line))) {
                var tm = tm_now
                tm.tm_hour = Int32(nsline.substringWithRange(m.rangeAtIndex(1)).toInt()!)
                tm.tm_min  = Int32(nsline.substringWithRange(m.rangeAtIndex(2)).toInt()!)
                tm.tm_sec  = Int32(nsline.substringWithRange(m.rangeAtIndex(3)).toInt()!)
                let sec = mktime(&tm)
                let subsec = UInt64(nsline.substringWithRange(m.rangeAtIndex(4)).toInt()!)
                timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(mktime(&tm)))
            }

            if let m = re_bytes.firstMatchInString(line, options: nil, range: NSRange(location: 0, length: count(line))) {
                for s in nsline.substringWithRange(m.rangeAtIndex(1)).componentsSeparatedByString(" ") {
                    if count(s) == 4 {
                        let word = strtoul(s, nil, 16)
                        buf[idx]   = UInt8(word >> 8)
                        buf[idx+1] = UInt8(word & 0xff)
                        idx += 2
                    } else if count(s) == 2 {
                        let word = strtoul(s, nil, 16)
                        buf[idx] = UInt8(word & 0xff)
                        idx += 1
                    }
                }

            }
        }
        let data = NSData(bytes: buf, length: idx)
        if timestamp != nil {
            return Packet(timestamp: timestamp!, original_length: data.length, captured_length: data.length, data: data)
        } else {
            return nil
        }
    }
}
