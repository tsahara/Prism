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
        if false {
            let h = Helper()
            h.install()
            h.connect {
                success in
                print("callback: \(success)")
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func executeCommand(_ sender: AnyObject) {
        print("exec")
    }
}
