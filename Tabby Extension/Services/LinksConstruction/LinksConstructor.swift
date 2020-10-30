//
//  LinksConstructor.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation

class LinksConstructor: LinksConstructing {
    private let emptyTitle = "Untitled"
    private let emptyAddress = "https://www.google.com"

    // Two formats supports pasting into certain PlainText/Markdown editors and rich text programs
    func links(from input: [LinkConstructingInput]) -> LinkResults {
        LinkResults(
            plain: input.map { getPlainTextLink(from: $0) },
            html: input.map { getHTMLLink(from: $0) }
        )
    }
}

private extension LinksConstructor {

    func getHTMLLink(from input: LinkConstructingInput) -> HTMLLink {
        let title = setTitleOrUntitled(from: input)
        let address = input.url?.absoluteString ?? emptyAddress
        let encodedTitle = convertAnyUTF8CharactersToHTMLReadyEncoding(from: title)
        let htmlString = String("""
            <p><a href="\(address)">\(encodedTitle)</a></p>
            """)
        return htmlString
    }

    func getPlainTextLink(from input: LinkConstructingInput) -> PlainTextLink {
        let title = setTitleOrUntitled(from: input)
        let address = input.url?.absoluteString ?? emptyAddress
        let friendlyAddress = dropHTTP(from: address)

        let plainString = String("""
            \(title)
            \(friendlyAddress)
            """)
        return plainString
    }

    func setTitleOrUntitled(from input: LinkConstructingInput) -> String {
        guard let title = input.title else { return emptyTitle }
        if title.isEmpty { return emptyTitle }
        else { return title }
    }

    func convertAnyUTF8CharactersToHTMLReadyEncoding(from string: String) -> String {
        let cfString = (string as NSString).mutableCopy() as! CFMutableString
        if CFStringTransform(cfString, nil, kCFStringTransformToXMLHex, false) {}
        return String(describing: cfString)
    }

    func dropHTTP(from string: String) -> String {
        if string.hasPrefix("http://") {
            return String(string.dropFirst(7))
        } else if string.hasPrefix("https://") {
            return String(string.dropFirst(8))
        } else {
            return string
        }
    }
}
