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
    
    init(data: Data, offset: Int) {
        var in4 = in_addr()
        withUnsafeMutablePointer(to: &in4) {
            ptr in
            memcpy(ptr, (data as NSData).bytes + offset, 4)
        }
        self.in4 = in4
    }
    
    var string: String {
        get {
            var in4 = self.in4
            var buf = Array<CChar>(repeating: 0, count: 16)
            inet_ntop(AF_INET, &in4, &buf, socklen_t(buf.count))
            return String(cString: &buf)
        }
    }
}
