//
//  AppDelegate.swift
//  Prism
//
//  Created by Tomoyuki Sahara on 2/24/15.
//  Copyright (c) 2015 Tomoyuki Sahara. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var netif: NetworkInterface?

//    func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
//        return false
//    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
//        NSDocumentController.sharedDocumentController().openDocument(self)
        
        netif = NetworkInterface(name: "en0")
        netif!.start()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}
