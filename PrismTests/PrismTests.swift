//
//  PrismTests.swift
//  PrismTests
//
//  Created by Tomoyuki Sahara on 2/24/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import XCTest
@testable import Prism

class PrismTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

    func testDataReader1Performance() {
        self.measure {
            let count = 1000 * 1000
            let reader = DataReader1(Data(count: count))
            for i in 0..<count {
                reader.read_u8()
                if reader.error {
                    
                }
            }
        }
    }

    func testDataReader2Performance() {
        self.measure {
            let count = 1000 * 1000
            let reader = DataReader2(Data(count: count))
            for i in 0..<count {
                try! reader.read_u8()
            }
        }
    }
}

class DataReader1 {
    let data: Data
    var offset: Int = 0
    var error: Bool = false

    init(_ data: Data) {
        self.data = data
    }

    func read_u8() -> UInt8 {
        if offset < data.count {
            let val = data[offset]
            offset += 1
            return val
        } else {
            error = true
            return 0
        }
    }
}

enum DataReaderError: Error {
    case outOfBound
}

class DataReader2 {
    let data: Data
    var offset: Int = 0

    init(_ data: Data) {
        self.data   = data
    }

    func read_u8() throws -> UInt8 {
        guard offset < data.count else {
            throw DataReaderError.outOfBound
        }
        let val = data[offset]
        offset += 1
        return val
    }
}
