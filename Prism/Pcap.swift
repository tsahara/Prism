//
//  Pcap.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/7/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

let PCAP_FILE_MAGIC: bpf_u_int32 = 0xa1b2c3d4

class Pcap {
    var packets: [Packet] = []
    var link_protocol: Protocol = UnknownProtocol()
    
    func encode() -> NSData {
        var hdr = pcap_file_header()
        hdr.magic = PCAP_FILE_MAGIC
        hdr.version_major = 2
        hdr.version_minor = 4
        hdr.thiszone = 0
        hdr.snaplen = 65536
        hdr.linktype = 0
        return NSData(bytes: &hdr, length: sizeof(pcap_file_header))
    }

    class func readFile(data: NSData) -> Pcap? {
        let reader = NSDataReader(data)

        if (data.length < sizeof(pcap_file_header)) {
            print("File too short (size=\(data.length))", terminator: "")
            return nil
        }

        let filehdr = UnsafePointer<pcap_file_header>(data.bytes).memory

        var endian: ByteOrder
        switch reader.u32() {
        case PCAP_FILE_MAGIC:
            endian = .BigEndian
        case PCAP_FILE_MAGIC.byteSwapped:
            endian = .LittleEndian
        default:
            print("bad magic: \(filehdr.magic.bigEndian)", terminator: "")
            return nil
        }
        reader.endian = endian
        
        print("linktype=\(filehdr.linktype)\n", terminator: "")
        reader.advance(20)

        let pcap = Pcap()
        
        while (reader.offset < data.length) {
            if (reader.offset + 16 > data.length) {
                print("short packet header!", terminator: "")
                return nil
            }
            let ts_sec  = reader.u32endian()
            let ts_usec = reader.u32endian()
            let caplen  = reader.u32endian()
            let origlen = reader.u32endian()
            
            if (reader.offset + Int(caplen) > data.length) {
                print("packets < caplen", terminator: "")
                return nil
            }

            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = NSDate(timeIntervalSinceReferenceDate: sec)

            let pkt = Packet(timestamp: date, original_length: Int(origlen), captured_length: Int(caplen), data: reader.readdata(Int(caplen)))
            let context = ParseContext(pkt.data, endian: endian, parser: LoopbackProtocol.parse)
            pkt.parse(context)

            pcap.packets.append(pkt)
        }
        return pcap
    }
}