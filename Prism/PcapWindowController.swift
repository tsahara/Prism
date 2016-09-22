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
    @IBOutlet weak var search_field: NSSearchFieldCell!

    @IBOutlet weak var packet_outline: NSOutlineView!

    var hexa: HexadumpWindowController?
    var selected_packet: Packet?
    var pcap: Pcap? { get { return (self.document as! PcapDocument?)?.pcap } }

    @IBAction func search(_ sender: AnyObject) {
        print("search: \(search_field.stringValue)")
    }

    override func windowDidLoad() {
//        window!.titleVisibility = .Hidden
        let center = NotificationCenter.default
        center.addObserver(forName: NSNotification.Name(rawValue: "AddPacketNotification"), object: pcap, queue: OperationQueue.main) {
            notification in
            self.packet_table.noteNumberOfRowsChanged()
        }
        print("loaded")
    }
    
    @IBAction func startstop(_ sender: AnyObject) {
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
    
    @IBAction func toolbar_hexadump(_ sender: AnyObject) {
        print("hexadump")
        hexa = HexadumpWindowController(windowNibName: "HexadumpWindow")
        hexa!.showWindow(nil)
    }

    @IBAction func ReadText(_ sender: AnyObject) {
        if let pkt = Packet.parseText(text.string!) {
            pcap!.packets.append(pkt)
            packet_table.reloadData()
        } else {
            print("parse error!!")
        }
    }
    
    // NSTableViewDataSource Protocol
    func numberOfRows(in aTableView: NSTableView) -> Int {
        if pcap != nil {
            return pcap!.packets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
        let pkt = pcap!.packets[rowIndex]
        
        let label = aTableColumn!.identifier
        switch label {
        case "TimeCell":
            let f = DateFormatter()
            f.dateFormat = "HH:mm:ss"
            let subsec = String(format: ".%9u", Int(pkt.timestamp.timeIntervalSince1970 * 1000000000))
            return f.string(from: pkt.timestamp as Date) + subsec
            
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let pcap = pcap else { return }
        self.selected_packet = pcap.packets[packet_table!.selectedRow]
        self.packet_outline.reloadItem(nil)
    }

    
    // Outline View Programming Topics
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/OutlineView/OutlineView.html
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            guard let pkt = self.selected_packet else { return 0 }
            return pkt.protocols.count
        } else {
            let proto = item as! Protocol
            return proto.fields.count
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is Protocol {
            let proto = item as! Protocol
            if proto.fields.count > 0 {
                return true
            }
        }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            guard let pkt = selected_packet else { return "(???)" }
            return pkt.protocols[index]
        } else {
            let proto = item as! Protocol
            return proto.fields[index]
        }
    }

    func outlineView(_ outlineView: NSOutlineView,
        objectValueFor tableColumn: NSTableColumn?,
        byItem item: Any?) -> Any? {
            if item is Protocol {
                return (item as! Protocol).name
            } else {
                return (item as! ProtocolField).interpretation()
            }
    }
}
