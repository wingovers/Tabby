//
//  Strings.swift
//  Tabby the Copycat
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation

enum Strings: String {
    case buttonCommandLabelBase = "Enable Tabby by checking\u{2028}its box in Safari Preferences."
    case buttonCommandLabelInstalled = "Your Tabby is now installed!"
    case rightClickHeadlineLabelBase = "Right click to close duplicate tabs"
    case rightClickCopyLabelBase = "or copy links to one side or from all windows"
    case toolbarTapHeadlineLabelBase = "Tap the toolbar cat\u{2028}to copy links for all tabs"
    case openSafariButtonBase = "Open Safari Preferences"
    case catalinaWarning = "If installing fails, try wiggling \nthe window. Catalina has a sporadic bug for all extensions."
    case catalinaPlaceholder = ""
    case privacyStatment = "Privacy: Tabby collects no data from you, period.\u{2028}Verify the source code yourself at github.com/wingovers/Tabby"

    var english: String { self.rawValue }
}
