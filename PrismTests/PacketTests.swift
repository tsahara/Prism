//
//  PacketTests.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/5/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa
import XCTest

class PacketTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseText1() {
        let text_icmp6_echo =
            "21:31:01.116717 IP6 ::1 > ::1: ICMP6, echo request, seq 0, length 16\n" +
            "   0x0000:  6000 a182 0010 3a40 0000 0000 0000 0000  `.....:@........\n" +
            "   0x0010:  0000 0000 0000 0001 0000 0000 0000 0000  ................\n" +
            "   0x0020:  0000 0000 0000 0001 8000 99b9 4d46 0000  ............MF..\n" +
        "   0x0030:  53df 7d05 0001 c7cd                      S.}.....\n"
        let pkt = Packet.parseText(text_icmp6_echo)

        XCTAssertNotNil(pkt, "Pass")
        XCTAssertEqual(pkt!.captured_length, 56)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
