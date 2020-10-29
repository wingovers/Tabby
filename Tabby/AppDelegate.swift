//
//  AppDelegate.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {}
    
    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApplication.shared.windows.first?.makeKeyAndOrderFront(nil)
        if flag { return false }
        else { return true }
    }
}
