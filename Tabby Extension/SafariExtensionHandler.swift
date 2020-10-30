//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    let badge: BadgeUpdating
    let clipboard: Clipboarding
    let close: TabClosing
    let construct: LinksConstructing
    let extracted: SafariExtracting

    override init() {
        badge = BadgeUpdateAgent()
        clipboard = ClipboardAgent()
        close = TabCloser()
        construct = LinksConstructor()
        extracted = SafariExtractor()
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        let links = construct.links(from: extracted.pages(in: window))
        badge.update(window, with: links.count)
        clipboard.copy(links)
    }

    override func contextMenuItemSelected(withCommand command: String,
                                          in page: SFSafariPage,
                                          userInfo: [String : Any]? = nil) {
        switch command {

        case "copyTab":
            let links = construct.links(from: extracted.page(in: page))
            clipboard.copy(links)
            badge.updateWindow(of: page, with: links.count)
            
        case "copyRight":
            let links = construct.links(from: extracted.pages(to: .right, of: page))
            clipboard.copy(links)
            badge.updateWindow(of: page, with: links.count)

        case "copyLeft":
            let links = construct.links(from: extracted.pages(to: .left, of: page))
            clipboard.copy(links)
            badge.updateWindow(of: page, with: links.count)

        case "copyAllWindows":
            let links = construct.links(from: extracted.allSafariWindows())
            clipboard.copy(links)
            badge.updateWindow(of: page, with: links.count)

        case "closeDupes":
            close.duplicates(in: extracted.tabs(fromWindowContaining: page))

        default:
            NSLog("Unknown context menu command received.")
        }
    }
}
