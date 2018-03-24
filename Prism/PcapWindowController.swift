//
//  PcapWindowController.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 11/21/15.
//  Copyright © 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

class PcapWindowController : NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource {
    @IBOutlet weak var packet_table: NSTableView!

    @IBOutlet var text: NSTextView!
    @IBOutlet weak var search_field: NSSearchFieldCell!

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var packet_outline: NSOutlineView!

    var hexa: HexadumpWindowController?
    var selected_packet: Packet?
    var pcap: Pcap? { get { return (self.document as! PcapDocument?)?.pcap } }

    @IBAction func search(_ sender: AnyObject) {
        print("search: \(search_field.stringValue)")
    }

    override func windowDidLoad() {
        let center = NotificationCenter.default
        center.addObserver(forName: NSNotification.Name(rawValue: "AddPacketNotification"), object: pcap, queue: OperationQueue.main) {
            notification in
            NSLog("add-packet-notification")
            self.packet_table.noteNumberOfRowsChanged()
            self.label.stringValue = "packets count = \(self.pcap?.packets.count)"
        }
        label.stringValue = "loaded"

        NotificationCenter.default.post(name: Notification.Name(rawValue: "AddPacketNotification"), object: pcap!)
        NSLog("windowDidLoad: cnt==\(self.pcap!.packets.count)")
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
        hexa = HexadumpWindowController(windowNibName: NSNib.Name(rawValue: "HexadumpWindow"))
        hexa!.showWindow(nil)
    }

    @IBAction func ReadText(_ sender: AnyObject) {
        if let pkt = Packet.parseText(text.string) {
            pcap!.packets.append(pkt)
            packet_table.reloadData()
        } else {
            print("parse error!!")
        }
    }
    
    // NSTableViewDataSource Protocol
    func numberOfRows(in aTableView: NSTableView) -> Int {
        NSLog("numberOfRows: \(pcap?.packets.count)")
        if pcap != nil {
            return pcap!.packets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
        let pkt = pcap!.packets[rowIndex]
        
        switch aTableColumn!.title {
        case "Time":
            let f = DateFormatter()
            f.dateFormat = "HH:mm:ss"
            let subsec = String(format: ".%9u", Int(pkt.timestamp.timeIntervalSince1970 * 1000000000))
            return f.string(from: pkt.timestamp as Date) + subsec
            
        case "Source":
            if (pkt.ipv4 != nil) {
                return pkt.ipv4!.src!.string
            } else if (pkt.ipv6 != nil) {
                return pkt.ipv6!.src!.string
            }
            return pkt.src_string
            
        case "Src Port":
            if (pkt.tcp != nil) {
                return String(pkt.tcp!.srcport)
            } else if (pkt.udp != nil) {
                return String(pkt.udp!.srcport!)
            }
            return ""
            
        case "Destination":
            if (pkt.ipv4 != nil) {
                return pkt.ipv4!.dst!.string
            }
            if (pkt.ipv6 != nil) {
                return pkt.ipv6!.dst!.string
            }
            return pkt.dst_string
            
        case "Dst Port":
            if (pkt.tcp != nil) {
                return String(pkt.tcp!.dstport)
            } else if (pkt.udp != nil) {
                return String(pkt.udp!.dstport!)
            }
            return ""
            
        case "Protocol":
            return pkt.proto
            
        case "Summary":
            return "summary"

        default:
            return "(no value)"
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let pcap = pcap else { return }
        if packet_table!.selectedRow < 0 { return }
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
