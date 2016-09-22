//
//  ProtocolField.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 1/3/16.
//  Copyright © 2016 Tomoyuki Sahara. All rights reserved.
//

import Foundation

@objc class ProtocolField : NSObject {
    let name: String
    
    let data: Data
    let offset: Int
    let length: Int
    
    init(reader: DataReader, length: Int, name: String) {
        self.data = reader.data as Data
        self.offset = reader.offset
        self.length = length
        self.name = name
    }
    
    func interpretation() -> String {
        return self.name
    }
}
