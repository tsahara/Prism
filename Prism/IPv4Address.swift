//
//  IPv4Address.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 8/28/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation

struct IPv4Address {
    var in4: in_addr
    
    init(data: NSData, offset: Int) {
        var in4 = in_addr()
        withUnsafeMutablePointer(&in4) {
            ptr in
            memcpy(ptr, data.bytes + offset, 4)
        }
        self.in4 = in4
    }
    
    var string: String {
        get {
            var in4 = self.in4
            var buf = Array<CChar>(count: 16, repeatedValue: 0)
            inet_ntop(AF_INET, &in4, &buf, socklen_t(buf.count))
            return String.fromCString(&buf)!
        }
    }
}
