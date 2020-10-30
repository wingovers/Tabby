//
//  BadgeUpdating.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

protocol BadgeUpdating {
    func update(_ window: SFSafariWindow, with count: Int)
    func updateWindow(of page: SFSafariPage, with count: Int)
}

