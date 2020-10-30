//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Foundation
import SafariServices

func nowInSeconds() -> Int {
    let now = Calendar.current.dateComponents([.second], from: Date())
    return now.second!

}

class SafariExtractor: SafariExtracting {

    func page(in page: SFSafariPage) -> [LinkConstructingInput] {
        propertiesOfActivePages(from: Array(arrayLiteral: page))
            .asLinkInput()
    }

    func pages(in window: SFSafariWindow) -> [LinkConstructingInput] {
        NSLog("\(#function) start \(nowInSeconds())")
        let result = propertiesOfActivePages(from: everyPageInside(window))
            .asLinkInput()
        NSLog("\(#function) end \(nowInSeconds())")
        return result
    }

    func pages(to side: SliceDirection, of page: SFSafariPage) -> [LinkConstructingInput] {
        propertiesOfActivePages(from: pages(to: side, of: page))
            .asLinkInput()
    }

    func allSafariWindows() -> [LinkConstructingInput] {
        var allPages = [SFSafariPage]()

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            SFSafariApplication.getAllWindows { windows in
                windows.enumerated().forEach { [self] (index, window) in
                    allPages.append(contentsOf: everyPageInside(window))
                    guard index == (windows.count - 1) else { return }
                    group.leave()
                }
            }
        }
        _ = group.wait(timeout: .now() + 1)
        return propertiesOfActivePages(from: allPages).asLinkInput()
    }

    func tabs(surrounding page: SFSafariPage) -> [SFSafariTab] {
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

    func everyPageInside(_ window: SFSafariWindow) -> [SFSafariPage] {
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


    func pages(to side: SliceDirection, of page: SFSafariPage) -> [SFSafariPage] {
        var allPages = [SFSafariPage]()

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
