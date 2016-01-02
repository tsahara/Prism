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
    /// packets in PCAP
    var packets: [Packet] = []
    
    /// capturing or not
    var capturing = false
    
    /// Network interface on which capturing is going
    var netif: NetworkInterface?

    /**
     encode to PCAP file format.
     
     - returns: byte sequence.
     */
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

    /**
     read PCAP file.
     
     - returns: PCAP object.
     */
    class func readFile(controller: PcapWindowController, data: NSData) -> Pcap? {
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
        reader.advance(16)
        
        let linktype = reader.u32le()
        print("linktype=\(linktype)\n", terminator: "")
        
        var parser: (ParseContext) -> Protocol
        switch linktype {
        case 1:
            parser = Ethernet.parse
        default:
            parser = LoopbackProtocol.parse
        }

        let pcap = Pcap()
        
        while (reader.offset < data.length) {
            if (reader.offset + 16 > data.length) {
                print("short packet header!")
                return nil
            }
            let ts_sec  = reader.u32endian()
            let ts_usec = reader.u32endian()
            let caplen  = reader.u32endian()
            let origlen = reader.u32endian()
            
            if (reader.offset + Int(caplen) > data.length) {
                print("packets < caplen")
                return pcap
            }

            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = NSDate(timeIntervalSinceReferenceDate: sec)

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
            let reader = NSDataReader(data)
            let endian = ByteOrder.host()
            reader.endian = endian

            if (reader.offset + 16 > data.length) {
                print("BPF: short packet header!")
                return
            }
            let ts_sec  = reader.u32endian()
            let ts_usec = reader.u32endian()
            let caplen  = reader.u32endian()
            let origlen = reader.u32endian()
            let hdrlen  = reader.u16endian()
            
            if (reader.offset + Int(caplen) > data.length) {
                print("BPF: packets < caplen")
                return
            }
            
            let sec = Double(ts_sec) + 1.0e-6 * Double(ts_usec)
            let date = NSDate(timeIntervalSinceReferenceDate: sec)
            
            let pkt = Packet(timestamp: date, original_length: Int(origlen), captured_length: Int(caplen), data: reader.readdata(Int(caplen)))
            //print(pkt.data)
            let parser = Ethernet.parse
            let context = ParseContext(pkt.data, endian: endian, parser: parser)
            pkt.parse(context)

            self.packets.append(pkt)
            
            let center = NSNotificationCenter.defaultCenter()
            center.postNotificationName("AddPacketNotification", object: self)
        }
    }

    func stop_capture() {
        self.capturing = false
        netif?.stop()
        print("stop capture")
    }
}
