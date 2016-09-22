//
//  MacAddressField.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 1/3/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class MacAddressField : ProtocolField {
    override func interpretation() -> String {
        let cp = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count) + offset
        let val = (0..<6).map { i in String(format: "%02x", cp[i]) }.joined(separator: ":")
        return "\(name): \(val)"
    }
}
