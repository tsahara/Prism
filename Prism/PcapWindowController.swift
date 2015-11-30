//
//  PcapWindowController.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 11/21/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

class PcapWindowController : NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var packet_table: NSTableView!
    @IBOutlet var text: NSTextView!

    var pcap: Pcap { get { return (self.document as! PcapDocument).pcap } }

    override func windowDidLoad() {
//        window!.titleVisibility = .Hidden
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName("AddPacketNotification", object: pcap, queue: NSOperationQueue.mainQueue()) {
            notification in
            self.packet_table.noteNumberOfRowsChanged()
        }
        print("loaded")
    }
    
    @IBAction func startstop(sender: AnyObject) {
        let item = sender as! NSToolbarItem

        if pcap.capturing {
            pcap.stop_capture()
            item.label = "Start"
        } else {
            pcap.start_capture()
            item.label = "Stop"
        }
    }

    @IBAction func ReadText(sender: AnyObject) {
        if let pkt = Packet.parseText(text.string!) {
            pcap.packets.append(pkt)
            packet_table.reloadData()
        } else {
            print("parse error!!")
        }
    }
    
    // NSTableViewDataSource Protocol
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return pcap.packets.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
        let pkt = pcap.packets[rowIndex]
        
        let label = aTableColumn!.identifier
        switch label {
        case "TimeCell":
            let f = NSDateFormatter()
            f.dateFormat = "HH:mm:ss"
            let subsec = String(format: ".%9u", Int(pkt.timestamp.timeIntervalSince1970 * 1000000000))
            return f.stringFromDate(pkt.timestamp) + subsec
            
        case "SourceCell":
            if (pkt.ipv4 != nil) {
                return pkt.ipv4!.src!.string
            }
            if (pkt.ipv6 != nil) {
                return pkt.ipv6!.src!.string
            }
            return ""
            
        case "SourcePortCell":
            if (pkt.tcp != nil) {
                return String(pkt.tcp!.srcport!)
            } else if (pkt.udp != nil) {
                return String(pkt.udp!.srcport!)
            }
            return ""
            
        case "DestinationCell":
            if (pkt.ipv4 != nil) {
                return pkt.ipv4!.dst!.string
            }
            if (pkt.ipv6 != nil) {
                return pkt.ipv6!.dst!.string
            }
            return ""
            
            
        case "DestinationPortCell":
            if (pkt.tcp != nil) {
                return String(pkt.tcp!.dstport!)
            } else if (pkt.udp != nil) {
                return String(pkt.udp!.dstport!)
            }
            return ""
            
        case "ProtocolCell":
            return pkt.proto
            
        case "SummaryCell":
            return "summary"
        default:
            return "(no value)"
        }
    }
}