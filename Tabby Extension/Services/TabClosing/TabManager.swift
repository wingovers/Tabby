//
//  TabManager.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

class TabCloser: TabClosing {
    func duplicates(in tabs: [SFSafariTab]) {
        var uniqueURLs = Set<String>()
        
        tabs.forEach { tab in
            tab.getActivePage { page in
                page?.getPropertiesWithCompletionHandler { props in
                    guard let props = props,
                          props.isActive,
                          let url = props.url?.absoluteString
                    else { return }
                    if uniqueURLs.contains(url) {
                        DispatchQueue.main.async {
                            tab.close()
                        }
                    } else {
                        uniqueURLs.insert(url)
                    }
                }
            }
        }
    }
}
