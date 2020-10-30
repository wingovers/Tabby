//
//  ClipboardAgent.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import AppKit

class ClipboardAgent: Clipboarding {
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

