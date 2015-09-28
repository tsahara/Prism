//
//  Document.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2/24/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

class PcapDocument: NSDocument, NSTableViewDataSource, NSTableViewDelegate {
    var pcap: Pcap?
    
    @IBOutlet var text: NSTextView!

    @IBAction func ReadText(sender: AnyObject) {
        Packet.parseText(text.string!)
    }

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "PcapDocument"
    }

    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        
        //outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        
        if pcap == nil {
            pcap = Pcap()
        }
        return pcap!.encode()
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.

        pcap = Pcap.readFile(data)
        if pcap == nil {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
        }
        print("Read \(pcap!.packets.count) packets", terminator: "")
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
        if (pcap?.packets[rowIndex] == nil) {
            return "???"
        }
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
            }
            if (pkt.ipv6 != nil) {
                return pkt.ipv6!.src!.string
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

        case "ProtocolCell":
            return pkt.proto
            
        case "SummaryCell":
            return "summary"
        default:
            return "(no value)"
        }
    }
}
