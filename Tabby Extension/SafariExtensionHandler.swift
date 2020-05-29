//
//  AppDelegate.swift
//  Tabby
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    var HREFS = [String]()
    
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
    
    func copyToClipboard(fromWindow window: SFSafariWindow) {
        setBadge(ofWindow: window, contents: String("\(self.HREFS.count)"))
        NSPasteboard.general.clearContents()
        let toTheseLinks = self.HREFS.joined(separator: "\n")
        print(toTheseLinks)
        NSPasteboard.general.setString(toTheseLinks, forType: .html)
    }
    
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
    
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        switch command {
        case "copyTab":
            // Copy page link
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
            
        // Copy non-duplicate tabs, retaining just the leftmost instance
        case "copyUniques":
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
                                            }
                                            self.copyToClipboard(fromWindow: window!)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        
        // Close tabs producing duplicate links
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
