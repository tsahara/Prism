//
//  main.swift
//  behold
//
//  Created by Tomoyuki Sahara on 2018/03/07.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import Foundation

//let argv = CommandLine.arguments
let argv = ["a", "/Users/sahara/src/Unclog/stat.ripe.net.v4.pcap"]

guard argv.count == 2 else {
    print("usage: behold <pcapfile>")
    exit(1)
}

do {
    let filename = argv[1]
    let data = try Data(contentsOf: URL(fileURLWithPath: filename))
    let pcap = Pcap.readFile(data: data)
    if pcap != nil {
        print("read \(pcap!.packets.count) packets")
    } else {
        let pcapng = try Pcapng(data: data)
        print("read \(pcapng.packets.count) packets")
    }
} catch let PcapParseError.formatError(msg) {
    print("parse error: \(msg)")
    exit(1)
} catch {
    print("error while readling file")
    exit(1)
}


