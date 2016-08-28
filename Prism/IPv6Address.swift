//
//  IPv6Address.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 8/27/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation

struct IPv6Address {
    var in6: in6_addr

    init(data: NSData, offset: Int) {
        var in6 = in6_addr()
        withUnsafeMutablePointer(&in6) {
            ptr in
            memcpy(ptr, data.bytes + offset, 16)
        }
        self.in6 = in6
    }

    var string: String {
        get {
            var in6 = self.in6
            var buf = Array<CChar>(count: 60, repeatedValue: 0)
            inet_ntop(AF_INET6, &in6, &buf, socklen_t(buf.count))
            return String.fromCString(&buf)!
        }
    }
}
