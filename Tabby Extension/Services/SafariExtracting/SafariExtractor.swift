//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Foundation
import SafariServices

class SafariExtractor: SafariExtracting {

    func page(in page: SFSafariPage) -> [LinkConstructingInput] {
        propertiesOfActivePages(from: Array(arrayLiteral: page))
            .asLinkInput()
    }

    func pages(in window: SFSafariWindow) -> [LinkConstructingInput] {
        propertiesOfActivePages(from: pages(inside: window))
            .asLinkInput()
    }

    func pages(to side: SliceDirection, of page: SFSafariPage) -> [LinkConstructingInput] {
        propertiesOfActivePages(from: pages(to: side, of: page))
            .asLinkInput()
    }

    func allSafariWindows() -> [LinkConstructingInput] {
        propertiesOfActivePages(from: pages(inside: allWindows()))
            .asLinkInput()
    }

    func tabs(fromWindowContaining page: SFSafariPage) -> [SFSafariTab] {
        var allTabs = [SFSafariTab]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            page.getContainingTab { tab in
                tab.getContainingWindow { window in
                    guard let window = window else { return }
                    window.getAllTabs { tabs in
                        allTabs = tabs
                        group.leave()
                    }
                }
            }
        }
        _ = group.wait(timeout: .now() + 1)
        return allTabs
    }
}

private extension SafariExtractor {
    func propertiesOfActivePages(from pages: [SFSafariPage]) -> [SFSafariPageProperties] {
        var allProperties = [SFSafariPageProperties]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            pages.enumerated().forEach { (pageIndex, page) in
                page.getPropertiesWithCompletionHandler { props in
                    guard let props = props,
                          props.isActive else { return }
                    allProperties.append(props)
                    guard pageIndex == (pages.count - 1) else { return }
                    group.leave()
                }
            }
        }
        _ = group.wait(timeout: .now() + 2)
        return allProperties
    }

    func pages(inside window: SFSafariWindow) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            window.getAllTabs { tabs in
                tabs.enumerated().forEach { (index, tab) in
                    tab.getActivePage { page in
                        guard let page = page else { return }
                        allPages.append(page)
                        guard index == (tabs.count - 1) else { return }
                        group.leave()
                    }
                }
            }
        }
        _ = group.wait(timeout: .now() + 2)
        return allPages
    }

    func pages(inside windows: [SFSafariWindow]) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global().async {
            windows.enumerated().forEach { (windowIndex, window) in
                window.getAllTabs { tabs in
                    tabs.enumerated().forEach { (tabIndex, tab) in
                        tab.getActivePage { page in
                            guard let page = page else { return }
                            allPages.append(page)
                            guard tabIndex == (tabs.count - 1),
                                  windowIndex == (windows.count - 1)
                                  else { return }
                            group.leave()
                        }
                    }
                }
            }
        }
        _ = group.wait(timeout: .now() + 3)
        return allPages
    }

    func pages(to side: SliceDirection, of page: SFSafariPage) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()

        let allTabs = tabs(fromWindowContaining: page)
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

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            tabSlice.enumerated().forEach { (index, tab) in
                tab.getActivePage { page in
                    guard let page = page else { return }
                    allPages.append(page)
                    guard index == (tabSlice.count - 1) else { return }
                    group.leave()
                }
            }
        }
        _ = group.wait(timeout: .now() + 2)
        return allPages
    }

    func allWindows() -> [SFSafariWindow] {
        var allWindows = [SFSafariWindow]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            SFSafariApplication.getAllWindows { windows in
                windows.enumerated().forEach { (index, window) in
                    allWindows.append(window)
                    guard index == (windows.count - 1) else { return }
                    group.leave()
                }
            }
        }
        _ = group.wait(timeout: .now() + 1)
        return allWindows
    }

    func currentTab(of page: SFSafariPage) -> SFSafariTab? {
        var currentTab: SFSafariTab?

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            page.getContainingTab { tab in
                currentTab = tab
                group.leave()
            }
        }
        _ = group.wait(timeout: .now() + 1)
        return currentTab
    }
}
