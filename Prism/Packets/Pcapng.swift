//
//  Pcapng.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2018/03/13.
//  Copyright © 2018 Tomoyuki Sahara. All rights reserved.
//

import Foundation

let SECTION_LENGTH_NOT_SPECIFIED = UINT64_MAX - 1

class Pcapng {
    var packets: [Packet] = []

    var major_version: UInt16
    var minor_version: UInt16

    init(data: Data) throws {
        let PCAPNG_FILE_MAGIC: UInt32 = 0x1a2b3c4d

        print("parsing as pcap-ng...")
        let reader = DataReader(data)
        guard reader.read_u32() == BlockType.Header.rawValue else { throw PcapParseError.formatError(msg: "bad magic") }
        let len_bigendian = reader.read_u32be()
        let magic = reader.read_u32be()

        var total_length: UInt32 = 0
        if magic == PCAPNG_FILE_MAGIC {
            reader.endian = .bigEndian
            total_length  = len_bigendian
        } else if magic == PCAPNG_FILE_MAGIC.byteSwapped {
            reader.endian = .littleEndian
            total_length  = len_bigendian.byteSwapped
        } else {
            // Error
        }

        major_version = reader.read_u16()
        minor_version = reader.read_u16()

        let section_length = reader.read_u64()
        print("sec len = \(section_length)")

        reader.skip(Int(total_length) - 24)

        let block_type = reader.read_u32()
    }
}

enum PcapParseError: Error {
    case formatError(msg: String)
}

enum BlockType: UInt32 {
    case Header = 0x0a0d0d0a
    case InterfaceDescription = 1
}

class Section {
    var byte_order_magic: UInt32
    var major_version: UInt16
    var minor_version: UInt16

    init(reader: DataReader) throws {

    }
}

class InterfaceDescription {
    let id: UInt16
    let linktype: UInt16
    let snaplen: UInt32

    init(reader: DataReader, id: UInt16) throws {
        self.id = id
        let block_total_length = reader.read_u32()
        self.linktype = reader.read_u16()
        reader.skip16()
        self.snaplen = reader.read_u32()

        // skip options
        reader.skip(Int(block_total_length) - 16)
    }
}
