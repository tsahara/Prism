//
//  IPv4AddressTest.swift
//  PrismTests
//
//  Created by Tomoyuki Sahara on 2018/03/01.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import XCTest
@testable import Prism

class IPv4AddressTest: XCTestCase {

    func testString() {
        let a = IPv4Address(data: Data(bytes: [192, 0, 2, 1]), offset: 0)
        XCTAssertEqual(a.string, "192.0.2.1")
    }
}
