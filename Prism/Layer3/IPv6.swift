//
//  IPv6.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class IPv6 : BaseProtocol {
    override var name: String { get { return "IPv6" } }
    override var isNetworkProtocol: Bool { get { return true } }
    
    override class func parse(context: ParseContext) -> Protocol {
        let p = IPv6()

        let reader = context.reader
        if (reader.length < 40) {
            p.broken = true
            return p
        }

        context.parser = nil
        return p
    }

}
