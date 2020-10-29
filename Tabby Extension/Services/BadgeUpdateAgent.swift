//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Foundation
import SafariServices

class BadgeUpdateAgent {

    // Winks toolbar icon cat + flashes link count
    func update(_ window: SFSafariWindow, with count: Int) {
        let wink = NSImage(named: "ToolbarItemIconCopied.pdf")
        let unwink: NSImage? = nil

        window.getToolbarItem { toolbar in
            toolbar?.setImage(wink)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                toolbar?.setImage(unwink)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                toolbar?.setBadgeText(String(count))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                toolbar?.setBadgeText(nil)
            }
        }
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
