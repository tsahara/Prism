//
//  IPv4AddressField.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 1/4/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class IPv4AddressField : ProtocolField {
    override func interpretation() -> String {
        let cp = UnsafePointer<UInt8>(data.bytes) + offset
        let val = (0..<4).map { i in String(format: "%u", cp[i]) }.joinWithSeparator(".")
        return "\(name): \(val)"
    }
}
