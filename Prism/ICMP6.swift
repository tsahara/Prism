//
//  ICMP6.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/21/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class ICMP6 : BaseProtocol {
    override var name: String { get { return "ICMP6" } }
    
    override class func parse(context: ParseContext) -> Protocol {
        var p = ICMP6()
       
        let r = context.reader
        if (r.length < 8) {
            p.broken = true
            return p
        }

        return p
    }
}
