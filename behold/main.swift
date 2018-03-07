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

//let pcap = Pcap.load(argv[1])
