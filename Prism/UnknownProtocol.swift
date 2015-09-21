//
//  UnknownProtocol.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class UnknownProtocol : BaseProtocol {
    override class func parse(context: ParseContext) -> Protocol {
        context.parser = nil
        return UnknownProtocol()
    }
}
