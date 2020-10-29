//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    var htmlLinks = [String]()
    var plainLinks = [String]()
    let extracted = TabExtractor()
    let construct = LinksConstructor()
    let clipboard = ClipboardAgent()
    let badge = BadgeUpdateAgent()

    override func toolbarItemClicked(in window: SFSafariWindow) {
        let links = construct.links(from: extracted.pages(in: window))
        clipboard.copy(links)
        badge.update(window, with: links.count)
    }
    
    // Right clicking a webpage offers options to copy the current page's link, copy tabs to the right, copy tabs to the left, and close any duplicate tabs
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        htmlLinks = [String]()
        plainLinks = [String]()

        switch command {
        case "copyTab":
            let links = construct.links(from: extracted.page(in: page))
            clipboard.copy(links)
            badge.updateWindow(of: page, with: links.count)
            
        case "copyRight":
            page.getContainingTab { tab in
                let currentTab = tab
                tab.getContainingWindow { window in
                    guard let _window = window else { return }
                    _window.getAllTabs { tabs in
                        guard let position = tabs.firstIndex(of: currentTab) else { return }
                        let rightTabs = tabs[position...]
                        
                        rightTabs.enumerated().forEach { (rightTabIndex, tab) in
                            tab.getActivePage { page in
                                page?.getPropertiesWithCompletionHandler { props in
                                    guard let _props = props,
                                          _props.isActive else { return }
                                    self.getLink(props: _props) { [weak self] (html, plain) in
                                        self?.htmlLinks.append(html)
                                        self?.plainLinks.append(plain)
                                        if rightTabIndex == (rightTabs.count - 1) {
                                            self?.copyToClipboard(fromWindow: _window)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
        case "copyLeft":
            page.getContainingTab { tab in
                let currentTab = tab
                tab.getContainingWindow { window in
                    guard let _window = window else { return }
                    _window.getAllTabs { tabs in
                        guard let position = tabs.firstIndex(of: currentTab) else { return }
                        let leftTabs = tabs[...position]
                        
                        leftTabs.enumerated().forEach { (leftTabIndex, tab) in
                            tab.getActivePage { page in
                                page?.getPropertiesWithCompletionHandler { props in
                                    guard let _props = props,
                                          _props.isActive else { return }
                                    self.getLink(props: _props) { [weak self] (html, plain) in
                                        self?.htmlLinks.append(html)
                                        self?.plainLinks.append(plain)
                                        if leftTabIndex == (leftTabs.count - 1) {
                                            self?.copyToClipboard(fromWindow: _window)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        // Close tabs containing duplicate links
        case "closeDupes":
            page.getContainingTab { (tab) in
                tab.getContainingWindow { window in
                    window?.getAllTabs { tabs in
                        tabs.forEach { tab in
                            tab.getActivePage { page in
                                page?.getPropertiesWithCompletionHandler { props in
                                    guard let _props = props,
                                          _props.isActive else { return }
                                    self.getLink(props: _props) { [weak self] (link, _) in
                                        if self?.htmlLinks.contains(link) == false {
                                            self?.htmlLinks.append(link)
                                        } else {
                                            tab.close()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        default:
            NSLog("Default")
        }
    }

    // MARK: - Functions

    // Two formats supports pasting into certain PlainText/Markdown editors and rich text programs
    func getLink(props: SFSafariPageProperties, completion: @escaping (String, String) -> Void) {
        let title = props.title ?? "Untitled"
        let address = props.url?.absoluteString ?? "http:\\www.google.com"

        // FOR HTML: Convert any UTF8 characters in the title to HTML-ready encoding
        let cfString = (title as NSString).mutableCopy() as! CFMutableString
        if CFStringTransform(cfString, nil, kCFStringTransformToXMLHex, false) {}
        let encoded = String(describing: cfString)
        let htmlString = String("""
            <p><a href="\(address)">\(encoded)</a></p>
            """)

        // FOR PLAIN TEXT: Remove http:// and https://
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

        completion(htmlString, plainString)
    }

    // Adds numerical badge for tabs copied + makes Tabby the cat wink by switching the default and copied icons
    func setBadge(ofWindow window: SFSafariWindow, contents: String) {
        window.getToolbarItem { toolbar in
            let image = NSImage(named: "ToolbarItemIconCopied.pdf")
            toolbar?.setImage(image)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                toolbar?.setImage(nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                toolbar?.setBadgeText(contents)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                toolbar?.setBadgeText(nil)
            }
        }
    }

    // Copies HTML hyperlinks in the current instance of the HREFS array and triggers the badge function
    func copyToClipboard(fromWindow window: SFSafariWindow) {
        setBadge(ofWindow: window, contents: String("\(self.htmlLinks.count)"))
        NSPasteboard.general.clearContents()
        let joinedHtmlLinks = self.htmlLinks.joined(separator: "\n")
        var joinedPlainLinks = self.plainLinks.joined(separator: "\n\n")
        joinedPlainLinks.append("\n")

        let plainAndHtmlLinksTogether = NSPasteboardItem()
        plainAndHtmlLinksTogether.setString(joinedHtmlLinks, forType: .html)
        plainAndHtmlLinksTogether.setString(joinedPlainLinks, forType: .string)

        NSPasteboard.general.writeObjects([plainAndHtmlLinksTogether])
    }
}
