//
//  Pcap.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 9/7/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Foundation

let PCAP_FILE_MAGIC: UInt32 = 0xa1b2c3d4

class Pcap {
    /// packets in PCAP
    var packets: [Packet] = []
    
    /// capturing or not
    var capturing = false
    
    /// Network interface on which capturing is going
    var netif: NetworkInterface?

    var endianness: ByteOrder = .littleEndian

    /// Header Fields
    var version_major: UInt16 = 0
    var version_minor: UInt16 = 0
    var thiszone: Int32 = 0         /* gmt to local correction */
    var sigfigs:  UInt32 = 0         /* accuracy of timestamps */
    var snaplen:  UInt32 = 0         /* max length saved portion of each pkt */
    var linktype: UInt32 = 0        /* data link type (DLT_*) */

    /**
     encode to PCAP file format.
     
     - returns: byte sequence.
     */
    func encode() -> Data {
//        var hdr = pcap_file_header()
//        hdr.magic = PCAP_FILE_MAGIC
//        hdr.version_major = 2
//        hdr.version_minor = 4
//        hdr.thiszone = 0
//        hdr.snaplen = 65536
//        hdr.linktype = 0
//        return withUnsafePointer(to: &hdr) {
//            ptr in Data(bytes: ptr, count: MemoryLayout<pcap_file_header>.size)
//        }
        return Data()
    }

    /**
     read PCAP file.
     
     - returns: PCAP object.
     */
    class func readFile(data: Data) -> Pcap? {
        guard data.count >= 20 else {
            // Error: file is too short
            return nil
        }

        let reader = DataReader(data)
        let magic = reader.read_u32be()

        let endian: ByteOrder
        switch magic {
        case PCAP_FILE_MAGIC:
            endian = .bigEndian
        case PCAP_FILE_MAGIC.byteSwapped:
            endian = .littleEndian
        default:
            print("bad magic: \(magic.bigEndian)", terminator: "")
            return nil
        }
        reader.endian = endian

        let pcap = Pcap()

        pcap.version_major = reader.read_u16()
        pcap.version_minor = reader.read_u16()
        pcap.thiszone      = reader.read_s32()
        pcap.sigfigs       = reader.read_u32()
        pcap.snaplen       = reader.read_u32()
        pcap.linktype      = reader.read_u32()

        print("linktype=\(pcap.linktype)\n", terminator: "")
        
        var parser: (ParseContext) -> Protocol
        switch pcap.linktype {
        case 1:
            parser = Ethernet.parse
        default:
            parser = LoopbackProtocol.parse
        }

        while (reader.offset < data.count) {
            if (reader.offset + 16 > data.count) {
                print("short packet header!")
                return nil
            }
            let ts_sec  = reader.u32endian()
            let ts_usec = reader.u32endian()
            let caplen  = reader.u32endian()
            let origlen = reader.u32endian()
            
            if (reader.offset + Int(caplen) > data.count) {
                print("packets < caplen")
                return pcap
            }

            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = Date(timeIntervalSinceReferenceDate: sec)

            let pkt = Packet(timestamp: date, original_length: Int(origlen), captured_length: Int(caplen), data: reader.readdata(Int(caplen)))
            let context = ParseContext(pkt.data, endian: endian, parser: parser)
            pkt.parse(context)

            pcap.packets.append(pkt)
        }
        return pcap
    }
    
    /**
    start capture
    */
    func start_capture() {
        self.capturing = true
        print("start capture")
        
        netif = NetworkInterface(name: "en0")
        netif!.on_receive {
            data in
            NSLog("pkt received")
            let reader = DataReader(data)
            let endian = ByteOrder.host()
            reader.endian = endian

            if (reader.offset + 16 > data.count) {
                print("BPF: short packet header!")
                return
            }
            let ts_sec  = reader.u32endian()
            let ts_usec = reader.u32endian()
            let caplen  = reader.u32endian()
            let origlen = reader.u32endian()
            let _  = reader.u16endian()
            
            if (reader.offset + Int(caplen) > data.count) {
                print("BPF: packets < caplen")
                return
            }
            
            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = Date(timeIntervalSinceReferenceDate: sec)
            
            let pkt = Packet(timestamp: date, original_length: Int(origlen), captured_length: Int(caplen), data: reader.readdata(Int(caplen)))
            //print(pkt.data)
            let parser = Ethernet.parse
            let context = ParseContext(pkt.data, endian: endian, parser: parser)
            pkt.parse(context)

            self.packets.append(pkt)
        }
    }

    func stop_capture() {
        self.capturing = false
        netif?.stop()
        print("stop capture")
    }
}
