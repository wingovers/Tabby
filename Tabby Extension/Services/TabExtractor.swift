//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Foundation
import SafariServices

class SafariExtractor {

    func page(in page: SFSafariPage) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: Array(arrayLiteral: page))
    }

    func pages(in window: SFSafariWindow) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: everyPageInside(window))
    }

    func pages(to side: SliceDirection, of page: SFSafariPage) -> [SFSafariPageProperties] {
        propertiesOfActivePages(from: pages(to: side, of: page))
    }

    enum SliceDirection {
        case left
        case right
    }

    func allSafariWindows() -> [SFSafariPageProperties] {
        var allPages = [SFSafariPage]()
        var isReady = false

        while !isReady {
            SFSafariApplication.getAllWindows { windows in
                windows.enumerated().forEach { [self] (index, window) in
                    allPages.append(contentsOf: everyPageInside(window))
                    guard index == (windows.count - 1) else { return }
                    isReady = true
                }
            }
        }

        return propertiesOfActivePages(from: allPages)
    }

    func tabs(surrounding page: SFSafariPage) -> [SFSafariTab] {
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
}

private extension SafariExtractor {

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


    func pages(to side: SliceDirection, of page: SFSafariPage) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()
        var isReady = false

        let allTabs = tabs(surrounding: page)
        guard let anchor = currentTab(of: page),
              let anchorPosition = allTabs.firstIndex(of: anchor)
        else { return allPages }
        var tabSlice = Array<SFSafariTab>.SubSequence()

        switch side {
            case .left:
                tabSlice = allTabs[...anchorPosition]
            case .right:
                tabSlice = allTabs[anchorPosition...]
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
