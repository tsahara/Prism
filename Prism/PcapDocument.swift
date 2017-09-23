//
//  Document.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2/24/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

class PcapDocument: NSDocument {
    var pcap: Pcap
    var controller: PcapWindowController?

    override init() {
        self.pcap = Pcap()
        super.init()
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        self.controller = aController as? PcapWindowController
    }

    override class var autosavesInPlace: Bool {
        return true
    }

//    override var windowNibName: String? {
//        // Returns the nib file name of the document
//        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
//        return "PcapDocument"
//    }
   
    override func makeWindowControllers() {
        self.addWindowController(PcapWindowController(windowNibName: NSNib.Name(rawValue: "PcapDocument")))
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        
        //outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)

        return pcap.encode() as Data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.

        guard let p = Pcap.readFile(data: data) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
        }
        printDocument("Read \(p.packets.count)")
    }
}
