//
//  ClipboardAgent.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

class ClipboardAgent {
    func copy(_ links: LinkResults) {
        let html = flatten(html: links.html)
        let plain = flatten(plain: links.plain)

        let pasteItem = NSPasteboardItem()
        pasteItem.setString(html, forType: .html)
        pasteItem.setString(plain, forType: .string)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([pasteItem])
    }
}

private extension ClipboardAgent {
    func flatten(html links: [HTMLLink]) -> String {
        links.joined(separator: "\n")
    }

    func flatten(plain links: [PlainTextLink]) -> String {
        links
            .joined(separator: "\n\n")
            .appending("\n")
    }
}

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
