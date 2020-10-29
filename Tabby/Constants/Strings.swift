//
//  Strings.swift
//  Tabby the Copycat
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation

enum Strings: String {

    case rightClickHeadline = "Right click webpages"
    case rightClickBullet1 = "close duplicate tabs"
    case rightClickBullet2 = "copy tabs across all windows"
    case rightClickBullet3 = "copy tabs on the left or right"

    case toolbarTapHeadline = "Tap the toolbar cat"
    case toolbarTapResult = "copy links for all tabs"

    case enableTabbyInstructions = "Enable Tabby by checking\u{2028}its box in Safari Preferences."
    case installed = "Your Tabby is now installed!"
    case openSafariPreferences = "Open Safari Preferences"

    case catalinaBugTitle = "􀇿 macOS Catalina Safari Bug"
    case catalinaWorkaround = "If the install checkbox fails, try first wiggling the panel. Close any night mode or window management apps."
    case catalinaBugLinkLabel = "Read more 􀰑"
    case blank = ""

    case privacyStatment = "Tabby collects no browsing data, period."
    case privacyLinkInvitation = "Open source at github.com/wingovers/Tabby"

    var english: String { self.rawValue }
}
