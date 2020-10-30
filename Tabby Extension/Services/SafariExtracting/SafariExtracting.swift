//
//  SafariExtracting.swift
//  Tabby the Copycat
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

protocol SafariExtracting {
    func page(in page: SFSafariPage) -> [LinkConstructingInput]
    func pages(in window: SFSafariWindow) -> [LinkConstructingInput]
    func pages(to side: SliceDirection, of page: SFSafariPage) -> [LinkConstructingInput]
    func allSafariWindows() -> [LinkConstructingInput]
    func tabs(surrounding page: SFSafariPage) -> [SFSafariTab]
}

enum SliceDirection {
    case left
    case right
}

extension Array where Element == SFSafariPageProperties {
    func asLinkInput() -> [LinkConstructingInput] {
        self.map {
            LinkConstructingInput(title: $0.title, url: $0.url)
        }
    }
}
