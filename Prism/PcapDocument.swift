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
        print("Read Button -> " + text.string!)
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

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        
        //outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        
        if pcap == nil {
            pcap = Pcap()
        }
        return pcap!.encode()
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.

        pcap = Pcap.readFile(data)
        print("Read \(count(pcap!.packets)) packets")
        
        //outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return true
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

        if let label = aTableColumn!.identifier {
            switch label {
            case "TimeCell":
                var f = NSDateFormatter()
                f.dateFormat = "HH:mm:ss.SSSSSS"
                return f.stringFromDate(pkt.timestamp)

            case "SourceCell":
                return "srcaddr"
            case "DestinationCell":
                return "dstaddr"
            case "ProtocolCell":
                return "proto"
            case "SummaryCell":
                return "summary"
            default:
                return "(no value)"
            }
        } else {
            return "(nil)"
        }
    }
}
