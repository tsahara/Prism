//
//  main.swift
//  behold
//
//  Created by Tomoyuki Sahara on 2018/03/07.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import Foundation

let argv = CommandLine.arguments

guard argv.count == 2 else {
    print("usage: behold <pcapfile>")
    exit(1)
}

do {
    let pcap = try Pcap.readFile(data: Data(contentsOf: URL(fileURLWithPath: argv[1])))
    print("read pcap file")
} catch {
    print("error while readling file")
}
