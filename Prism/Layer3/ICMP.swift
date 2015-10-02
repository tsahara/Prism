//
//  ICMP.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 10/2/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class ICMP : BaseProtocol {
    override var name: String { get { return "ICMP" } }
    
    override class func parse(context: ParseContext) -> Protocol {
        let p = ICMP(context)
        
        let r = context.reader
        if (r.length < 8) {
            p.broken = true
            return p
        }
        
        return p
    }
}
