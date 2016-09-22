//
//  Utils.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/22/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

extension in_addr {
    init(data: Data, offset: Int) {
        let reader = DataReader(data)
        self.s_addr = reader.read_u32be()
    }
    
    var string: String {
        get {
            var in4 = self
            var buf = Array<CChar>(repeating: 0, count: 16)
            inet_ntop(AF_INET, &in4, &buf, socklen_t(buf.count))
            return String(cString: &buf)
        }
    }
}
