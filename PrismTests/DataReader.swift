//
//  DataReaderTest.swift
//  PrismTests
//
//  Created by Tomoyuki Sahara on 2018/03/23.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import XCTest
@testable import Prism

class DataReaderTest: XCTestCase {
    
    let v = DataReader(Data(bytes: [0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]))

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_u8() {
        XCTAssertEqual(v.read_u8(), 0x01)
        XCTAssertEqual(v.read_u8(), 0x23)
    }

    func test_u16be() {
        XCTAssertEqual(v.read_u16be(), 0x0123)
        XCTAssertEqual(v.read_u16be(), 0x4567)
    }

    func test_s32be() {
        XCTAssertEqual(v.read_s32be(), 0x01234567)
        XCTAssertEqual(v.read_s32be(), -1985229329)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
