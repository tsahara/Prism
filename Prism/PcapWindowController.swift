//
//  PcapWindowController.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 11/21/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

let fuga = "FuGa"

class PcapWindowController : NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource {
    @IBOutlet weak var packet_table: NSTableView!

    @IBOutlet var text: NSTextView!

    @IBOutlet weak var packet_outline: NSOutlineView!

    var hexa: HexadumpWindowController?
    var selected_packet: Packet?
    var pcap: Pcap? { get { return (self.document as! PcapDocument?)?.pcap } }

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

        if pcap != nil {
            if pcap!.capturing {
                pcap!.stop_capture()
                item.label = "Start"
            } else {
                pcap!.start_capture()
                item.label = "Stop"
            }
        }
    }
    
    @IBAction func toolbar_hexadump(sender: AnyObject) {
        print("hexadump")
        hexa = HexadumpWindowController(windowNibName: "HexadumpWindow")
        hexa!.showWindow(nil)
    }

    @IBAction func ReadText(sender: AnyObject) {
        if let pkt = Packet.parseText(text.string!) {
            pcap!.packets.append(pkt)
            packet_table.reloadData()
        } else {
            print("parse error!!")
        }
    }
    
    // NSTableViewDataSource Protocol
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        if pcap != nil {
            return pcap!.packets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?, row rowIndex: Int) -> AnyObject? {
        let pkt = pcap!.packets[rowIndex]
        
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
            } else if (pkt.ipv6 != nil) {
                return pkt.ipv6!.src!.string
            }
            return pkt.src_string
            
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
            return pkt.dst_string
            
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
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let pcap = pcap else { return }
        self.selected_packet = pcap.packets[packet_table!.selectedRow]
        self.packet_outline.reloadItem(nil)
    }

    
    // Outline View Programming Topics
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/OutlineView/OutlineView.html
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        guard let pkt = self.selected_packet else { return 0 }
        return pkt.protocols.count
    }

    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return false
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        guard let pkt = selected_packet else { return "(???)" }
        return pkt.protocols[index]
    }

    func outlineView(outlineView: NSOutlineView,
        objectValueForTableColumn tableColumn: NSTableColumn?,
        byItem item: AnyObject?) -> AnyObject? {
            let proto = item as! Protocol
            return proto.name
    }
}