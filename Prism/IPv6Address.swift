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

    init(data: Data, offset: Int) {
        self.in6 = data.withUnsafeBytes {
            (p1: UnsafePointer<UInt8>) in
            (p1 + offset).withMemoryRebound(to: in6_addr.self, capacity: MemoryLayout<in6_addr>.size) {
                p2 in
                return p2.pointee
            }
        }
    }

    var string: String {
        get {
            var in6 = self.in6
            var buf = Array<CChar>(repeating: 0, count: 60)
            inet_ntop(AF_INET6, &in6, &buf, socklen_t(buf.count))
            return String(cString: &buf)
        }
    }
}
