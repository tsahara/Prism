//
//  Pcapng.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2018/03/13.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import Foundation

class Pcapng {
    var packets: [Packet] = []

    init(data: Data) throws {
        let PCAPNG_FILE_MAGIC: UInt32 = 0x1a2b3c4d

        print("parsing as pcap-ng...")
        let reader = DataReader(data)
        guard reader.read_u32() == BlockType.Header.rawValue else { throw PcapParseError.formatError(msg: "bad magic") }
        let len_bigendian = reader.read_u32be()
        let magic = reader.read_u32be()

        if magic == PCAPNG_FILE_MAGIC {
            // file byte order is big-endian.
            print("big-endian")
        } else if magic == PCAPNG_FILE_MAGIC.byteSwapped {
            // file byte order is little-endian.
            print("little-endian")
        }
    }
}

enum PcapParseError: Error {
    case formatError(msg: String)
}

enum BlockType: UInt32 {
    case Header = 0x0a0d0d0a
}
