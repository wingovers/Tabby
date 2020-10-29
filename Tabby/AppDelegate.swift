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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return false }
        else { return true }
    }
    
}

//https://stackoverflow.com/questions/30595478/how-do-you-re-open-a-closed-window-created-in-the-storyboard-in-os-x

//https://stackoverflow.com/questions/39400795/os-x-app-doesnt-launch-new-window-on-dock-icon-press-in-swift

//https://stackoverflow.com/questions/30921737/open-new-window-in-swift
