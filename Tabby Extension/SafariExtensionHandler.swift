//
//  SafariExtensionHandler.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    // Button taps and context menu actions append to unique instances of this string array
    var htmlLinks = [String]()
    var plainLinks = [String]()

    // MARK: - Intents
    
    // Pulls out properties for each Safari tab and then starts link creation, appends results to the HREFS array, and adds to pasteboard
    override func toolbarItemClicked(in window: SFSafariWindow) {
        window.getAllTabs { tabs in
            for tab in tabs {
                tab.getPagesWithCompletionHandler { pages in
                    pages?.forEach({ SFSafariPage in
                        SFSafariPage.getPropertiesWithCompletionHandler { props in
                            if props?.isActive == true {
                                self.getLink(props: props) { (html, plain) in
                                    self.htmlLinks.append(html)
                                    self.plainLinks.append(plain)
                                    self.copyToClipboard(fromWindow: window)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    // Right clicking a webpage offers options to copy the current page's link, copy tabs to the right, copy tabs to the left, and close any duplicate tabs
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        switch command {
        case "copyTab":
            // Copy the current page's link
            page.getPropertiesWithCompletionHandler { props in
                if props?.isActive == true {
                    self.getLink(props: props) { (html, plain) in
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(html, forType: .html)
                        NSPasteboard.general.setString(plain, forType: .string)
                    }
                }
            }
            
            // Update toolbar icon badge
            page.getContainingTab { tab in
                tab.getContainingWindow { window in
                    self.setBadge(ofWindow: window!, contents: "1")
                }
            }
            
        case "copyRight":
            page.getContainingTab { tab in
                let currentTab = tab
                tab.getContainingWindow { window in
                    window?.getAllTabs(completionHandler: { tabs in
                        let position = tabs.firstIndex(of: currentTab)
                        let rightTabs = tabs[position!...]
                        
                        rightTabs.forEach { tab in
                            tab.getActivePage { page in
                                page!.getPropertiesWithCompletionHandler { props in
                                    if props?.isActive == true {
                                        self.getLink(props: props) { (html, plain) in
                                            self.htmlLinks.append(html)
                                            self.plainLinks.append(plain)
                                            self.copyToClipboard(fromWindow: window!)
                                        }
                                    }
                                }
                            }
                        }
                        
                    })
                }
            }
            
            
        case "copyLeft":
            page.getContainingTab { tab in
                let currentTab = tab
                tab.getContainingWindow { window in
                    window?.getAllTabs(completionHandler: { tabs in
                        let position = tabs.firstIndex(of: currentTab)
                        let leftTabs = tabs[...position!]
                        
                        leftTabs.forEach { tab in
                            tab.getActivePage { page in
                                page!.getPropertiesWithCompletionHandler { props in
                                    if props?.isActive == true {
                                        self.getLink(props: props) { (html, plain) in
                                            self.htmlLinks.append(html)
                                            self.plainLinks.append(plain)
                                            self.copyToClipboard(fromWindow: window!)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    })
                }
            }
        
        // Close tabs containing duplicate links
        case "closeDupes":
            page.getContainingTab { (tab) in
                tab.getContainingWindow { (window) in
                    window?.getAllTabs { (tabs) in
                        tabs.forEach { tab in
                            tab.getActivePage { (page) in
                                page!.getPropertiesWithCompletionHandler { (properties) in
                                    if properties?.isActive == true {
                                        self.getLink(props: properties) { (link, _) in
                                            if self.htmlLinks.contains(link) == false {
                                                self.htmlLinks.append(link)
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
            }
            
            
        default:
            NSLog("How did you get default?")
        }
    }

    // MARK: - Functions

    // Unwraps a tab's URL and title, converts UTF8 encoding to encoding used by HTML, and wraps those strings into a line of HTML code
    func getLink(props: SFSafariPageProperties?, completion: @escaping (String, String) -> Void) {
        var unwrappedTitle = String()
        var unwrappedAddress = String()
        unwrappedTitle = props?.title ?? "Untitled"
        unwrappedAddress = props?.url?.absoluteString ?? "http:\\www.google.com"

        // FOR HTML: Convert any UTF8 characters in the title to HTML-ready encoding
        let cfString = (unwrappedTitle as NSString).mutableCopy() as! CFMutableString
        if CFStringTransform(cfString, nil, kCFStringTransformToXMLHex, false) {}
        let encoded = String(describing: cfString)
        let htmlString = String("""
            <li><a href="\(unwrappedAddress)">\(encoded)</a></li>
            """)

        // FOR PLAIN TEXT: Remove http:// and https://
        var friendlyAddress = String()
        if unwrappedAddress.hasPrefix("http://") {
            friendlyAddress = String(unwrappedAddress.dropFirst(7))
        }
        if unwrappedAddress.hasPrefix("https://") {
            friendlyAddress = String(unwrappedAddress.dropFirst(8))
        }
        let plainString = String("""
            \(unwrappedTitle)
            \(friendlyAddress)
            """)

            completion(htmlString, plainString)
    }


    // Flashes a badge on the toolbar icon for the number of tabs copied — and makes Tabby the cat wink
    func setBadge(ofWindow window: SFSafariWindow, contents: String) {
        window.getToolbarItem { (toolbar) in
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
        let toTheseLinks = self.htmlLinks.joined(separator: "\n")
        let toThesePlainLinks = self.plainLinks.joined(separator: "\n\n")

        let htmlObject = NSPasteboardItem()
        htmlObject.setString(toTheseLinks, forType: .html)

        let plainObject = NSPasteboardItem()
        plainObject.setString(toThesePlainLinks, forType: .string)

        var pasteArray = [NSPasteboardItem]()
        pasteArray.append(htmlObject)
        pasteArray.append(plainObject)

        NSPasteboard.general.writeObjects(pasteArray)
    }
}
