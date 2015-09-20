//
//  Protocol.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/15/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

protocol Protocol {
    var broken: Bool { get }

    var name: String { get }

    var isNetworkProtocol: Bool { get }
    
    static func parse(context: ParseContext) -> Protocol
}

class BaseProtocol: Protocol {
    var broken = false
    var name: String { get { return "(base)" } }
    var isNetworkProtocol: Bool { get { return false } }

    class func parse(context: ParseContext) -> Protocol {
        context.parser = nil
        return UnknownProtocol()
    }
}
