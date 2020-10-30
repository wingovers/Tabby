//
//  TabClosing.swift
//  Tabby the Copycat
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation
import SafariServices

protocol TabClosing {
    func duplicates(in tabs: [SFSafariTab])
}
