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
        let cp = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) + offset
        let val = (0..<4).map { i in String(format: "%u", cp[i]) }.joined(separator: ".")
        return "\(name): \(val)"
    }
}
