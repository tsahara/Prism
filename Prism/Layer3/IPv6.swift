//
//  IPv6.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class IPv6 : Protocol {
    override class func parse(context: ParseContext) -> Protocol {
        var p = IPv6()

        let reader = context.reader
        if (reader.length < 40) {
            p.broken = true
            return p
        }

        context.parser = nil
        return p
    }

}
