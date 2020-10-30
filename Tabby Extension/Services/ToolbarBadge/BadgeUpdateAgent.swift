//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Foundation
import SafariServices

class BadgeUpdateAgent: BadgeUpdating {
    private let wink = NSImage(named: "ToolbarItemIconCopied.pdf")
    private let unwink: NSImage? = nil
    private let winkingDuration = 0.3
    private let delayUntilReset = 1.5

    // Winks toolbar icon cat + flashes link count
    func update(_ window: SFSafariWindow, with count: Int) {
        NSLog("\(#function) start \(nowInSeconds())")
        window.getToolbarItem { [self] toolbar in
            toolbar?.setImage(wink)

            DispatchQueue.main.asyncAfter(deadline: .now() + winkingDuration) {
                toolbar?.setImage(unwink)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + winkingDuration) {
                toolbar?.setBadgeText(String(count))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delayUntilReset) {
                toolbar?.setBadgeText(nil)
            }
        }
        NSLog("\(#function) end \(nowInSeconds())")
    }

    func updateWindow(of page: SFSafariPage, with count: Int) {
        page.getContainingTab { tab in
            tab.getContainingWindow { [self] window in
                guard let window = window else { return }
                update(window, with: count)
            }
        }
    }
}
