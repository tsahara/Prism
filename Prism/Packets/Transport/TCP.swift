//
//  TCP.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 11/30/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class TCP : BaseProtocol {
    override var name: String { get { return "TCP" } }
    
    override class func parse(_ context: ParseContext) -> Protocol {
        let p = TCP(context)
        let reader = context.reader
        if (reader.length < 20) {
            p.broken = true
            return p
        }
        return p
    }

    var dstport: UInt16 {
        get {
            return UInt16(DataReader(data).get16be(at: 2))
        }
    }
    
    var srcport: UInt16 {
        get {
            return DataReader(data).get16be(at: 0)
        }
    }
}
