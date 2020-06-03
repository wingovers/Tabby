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
    var HREFS = [String]()
    
    // Unwraps a tab's URL and title, converts UTF8 encoding to encoding used by HTML, and wraps those strings into a line of HTML code
    func getLink(props: SFSafariPageProperties?, completion: @escaping (String) -> Void) {
        var unwrappedTitle = String()
        var unwrappedAddress = String()
        unwrappedTitle = props?.title ?? "Untitled"
        unwrappedAddress = props?.url?.absoluteString ?? "http:\\www.google.com"
        
        // Convert any UTF8 characters in the title to HTML-ready encoding
        let cfString = (unwrappedTitle as NSString).mutableCopy() as! CFMutableString
        if CFStringTransform(cfString, nil, kCFStringTransformToXMLHex, false) {}
        let encoded = String(describing: cfString)
        
        completion(String("""
            <li><a href="\(unwrappedAddress)">\(encoded)</a></li>
            """))
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
        setBadge(ofWindow: window, contents: String("\(self.HREFS.count)"))
        NSPasteboard.general.clearContents()
        let toTheseLinks = self.HREFS.joined(separator: "\n")
        NSPasteboard.general.setString(toTheseLinks, forType: .html)
    }
    
    // Pulls out properties for each Safari tab and then starts link creation, appends results to the HREFS array, and adds to pasteboard
    override func toolbarItemClicked(in window: SFSafariWindow) {
        window.getAllTabs { tabs in
            for tab in tabs {
                tab.getPagesWithCompletionHandler { pages in
                    pages?.forEach({ SFSafariPage in
                        SFSafariPage.getPropertiesWithCompletionHandler { props in
                            if props?.isActive == true {
                                self.getLink(props: props) { link in
                                    self.HREFS.append(link)
                                    self.copyToClipboard(fromWindow: window)
                                }
                            }
                        }
                    })
                }
            }
        }
    } // override
    
    // Right clicking a webpage offers options to copy the current page's link, copy tabs to the right, copy tabs to the left, and close any duplicate tabs
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        switch command {
        case "copyTab":
            // Copy the current page's link
            page.getPropertiesWithCompletionHandler { props in
                if props?.isActive == true {
                    self.getLink(props: props) { link in
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(link, forType: .html)
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
                                        self.getLink(props: props) { link in
                                            self.HREFS.append(link)
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
                                        self.getLink(props: props) { link in
                                            self.HREFS.append(link)
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
                                        self.getLink(props: properties) { link in
                                            if self.HREFS.contains(link) == false {
                                                self.HREFS.append(link)
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
}
