//
//  TabExtractor.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

class TabExtractor {
    func pages(in window: SFSafariWindow) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: everyPageInside(window))
    }

//    func pages(in pages: [SFSafariPage]) -> [SFSafariPageProperties] {
//        propertiesOfActivePages(from: pages)
//    }

    func page(in page: SFSafariPage) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: Array(arrayLiteral: page))
    }

    func pagesToRight(of page: SFSafariPage) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: pages(to: .right, of: page))
    }

    func pagesToLeft(of page: SFSafariPage) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: pages(to: .left, of: page))
    }
}

private extension TabExtractor {

    func everyPageInside(_ window: SFSafariWindow) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()
        var isReady = false

        while !isReady {
            window.getAllTabs { tabs in
                tabs.enumerated().forEach { (tabIndex, tab) in
                    tab.getPagesWithCompletionHandler { pages in
                        guard let pages = pages else { return }
                        allPages.append(contentsOf: pages)
                        guard tabIndex == (tabs.count - 1) else { return }
                        isReady = true
                    }
                }
            }
        }

        return allPages
    }

    func propertiesOfActivePages(from pages: [SFSafariPage]) -> [SFSafariPageProperties] {
        var allProperties = [SFSafariPageProperties]()
        var isReady = false

        while !isReady {
            pages.enumerated().forEach { (pageIndex, page) in
                page.getPropertiesWithCompletionHandler { props in
                    guard let props = props,
                          props.isActive else { return }
                    allProperties.append(props)
                    guard pageIndex == (pages.count - 1) else { return }
                    isReady = true
                }
            }
        }

        return allProperties
    }

    enum SliceDirection {
        case left
        case right
    }

    func pages(to side: SliceDirection, of page: SFSafariPage) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()
        var isReady = false

        let tabs = allTabs(surrounding: page)
        guard let anchor = currentTab(of: page),
              let anchorPosition = tabs.firstIndex(of: anchor)
        else { return allPages }
        var tabSlice = Array<SFSafariTab>.SubSequence()

        switch side {
            case .left:
                tabSlice = tabs[...anchorPosition]
            case .right:
                tabSlice = tabs[anchorPosition...]
        }

        while !isReady {
            tabSlice.enumerated().forEach { (index, tab) in
                tab.getActivePage { page in
                    guard let page = page else { return }
                    allPages.append(page)
                    if index == (tabSlice.count - 1) {
                        isReady = true
                    }
                }
            }
        }

        return allPages
    }

    func allTabs(surrounding page: SFSafariPage) -> [SFSafariTab] {
        var allTabs = [SFSafariTab]()
        var isReady = false

        while !isReady {
            page.getContainingTab { tab in
                tab.getContainingWindow { window in
                    guard let window = window else { return }
                    window.getAllTabs { tabs in
                        allTabs = tabs
                        isReady = true
                    }
                }
            }
        }

        return allTabs
    }

    func currentTab(of page: SFSafariPage) -> SFSafariTab? {
        var currentTab: SFSafariTab?
        var isReady = false
        while !isReady {
            page.getContainingTab { tab in
                currentTab = tab
                isReady = true
            }
        }
        return currentTab
    }
}

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
