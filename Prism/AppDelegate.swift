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
//    func applicationShouldOpenUntitledFile(sender: NSApplication) -> Bool {
//        return false
//    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        NSDocumentController.sharedDocumentController().openDocument(self)
        let h = Helper()
        h.install()
        h.connect {
            success in
            print("callbacked \(success)")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
