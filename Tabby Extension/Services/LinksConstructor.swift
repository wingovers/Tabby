//
//  LinksConstructor.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

class LinksConstructor {
    // Two formats supports pasting into certain PlainText/Markdown editors and rich text programs
    func links(from properties: [SFSafariPageProperties]) -> LinkResults {
        LinkResults(
            plain: properties.map { getPlainTextLink(from: $0) },
            html: properties.map { getHTMLLink(from: $0) }
        )
    }

    private let emptyTitle = "Untitled"
    private let emptyAddress = "https:\\www.google.com"
}

struct LinkResults {
    let plain: [PlainTextLink]
    let html: [HTMLLink]
    var count: Int { html.count }
}

private extension LinksConstructor {

    func getHTMLLink(from props: SFSafariPageProperties) -> HTMLLink {
        let title = props.title ?? emptyTitle
        let address = props.url?.absoluteString ?? emptyAddress

        // FOR HTML: Convert any UTF8 characters in the title to HTML-ready encoding
        let cfString = (title as NSString).mutableCopy() as! CFMutableString
        if CFStringTransform(cfString, nil, kCFStringTransformToXMLHex, false) {}
        let encoded = String(describing: cfString)
        let htmlString = String("""
            <p><a href="\(address)">\(encoded)</a></p>
            """)
        return htmlString
    }

    func getPlainTextLink(from props: SFSafariPageProperties) -> PlainTextLink {
        let title = props.title ?? emptyTitle
        let address = props.url?.absoluteString ?? emptyAddress

        var friendlyAddress = String()
        if address.hasPrefix("http://") {
            friendlyAddress = String(address.dropFirst(7))
        }
        if address.hasPrefix("https://") {
            friendlyAddress = String(address.dropFirst(8))
        }
        let plainString = String("""
            \(title)
            \(friendlyAddress)
            """)
        return plainString
    }

}

typealias PlainTextLink = String
typealias HTMLLink = String
