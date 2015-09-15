//
//  Protocol.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class Protocol {
    var broken = false
    
    class func parse(context: ParseContext) -> Protocol {
        context.parser = nil
        return UnknownProtocol()
    }
}
