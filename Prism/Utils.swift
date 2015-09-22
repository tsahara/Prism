//
//  Utils.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/22/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation


extension in6_addr {
    init(data: NSData, offset: Int) {
        memcpy(&self, data.bytes + offset, 16)
    }

    var string: String {
        get {
            var in6 = self
            var buf = Array<CChar>(count: 50, repeatedValue: 0)
            inet_ntop(AF_INET6, &in6, &buf, socklen_t(buf.count))
            return String.fromCString(&buf)!
        }
    }
}
