//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    let clipboard = ClipboardAgent()
    let badge = BadgeUpdateAgent()
    let close = TabCloser()

    let extracted = SafariExtractor()
    let construct = LinksConstructor()

    override func toolbarItemClicked(in window: SFSafariWindow) {
        let links = construct.links(from: extracted.pages(in: window))
        clipboard.copy(links)
        badge.update(window, with: links.count)
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
            close.duplicates(in: extracted.tabs(surrounding: page))

        default:
            NSLog("Unknown context menu command received.")
        }
    }
}
