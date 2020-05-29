//
//  AppDelegate.swift
//  Tabby
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBOutlet weak var rightClickHeadlineLabel: NSTextField!
    @IBOutlet weak var rightClickCopyLabel: NSTextField!
    @IBOutlet weak var toolbarTapHeadlineLabel: NSTextField!
    @IBOutlet weak var toolbarTapCopyLabel: NSTextField!
    @IBOutlet weak var buttonCommandLabel: NSTextField!
    @IBOutlet weak var openSafariExtensionPreferences: NSButton!
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.wantsLayer = true
        let bgImage = NSImage(named: "Install")
        self.view.layer!.contents = bgImage
        view.window?.backgroundColor = .clear
        view.window?.isOpaque = false
        view.window?.isMovableByWindowBackground = true
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Strings
        let buttonCommandLabelBase = "To install, enable Tabby\u{2028} in Safari Preferences."
        let rightClickHeadlineLabelBase = "Right click a page to clear"
            // - rightClick copy below
        let toolbarTapHeadlineLabelBase = "Tap the toolbar cat"
        let toolbarTapCopyLabelBase = "to copy links for all tabs"
        let openSafariButtonBase = "Open Safari Preferences"
        
        // Multiline string to attribute with line spacing
        let rightClickCopyLabelBase:String = "a thicket of duplicate tabs\u{2028}or copy links for\u{2028}– that page\u{2028}– tabs to the right or left\u{2028}– all tabs sans duplicates"

        // Attribution
        let spacedP:NSMutableParagraphStyle = NSMutableParagraphStyle()
        spacedP.lineSpacing = 5
        spacedP.paragraphSpacing = 20
        let attribs = [NSAttributedString.Key.paragraphStyle:spacedP]
        let rightClickCopyLabelAttr:NSAttributedString = NSAttributedString.init(string: rightClickCopyLabelBase, attributes: attribs)
        
        // Set labels
        self.toolbarTapHeadlineLabel.stringValue = toolbarTapHeadlineLabelBase
        self.toolbarTapCopyLabel.stringValue = toolbarTapCopyLabelBase
        self.rightClickHeadlineLabel.stringValue = rightClickHeadlineLabelBase
        self.rightClickCopyLabel.attributedStringValue = rightClickCopyLabelAttr
        self.buttonCommandLabel.stringValue = buttonCommandLabelBase
        self.openSafariExtensionPreferences.title = openSafariButtonBase
        
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "wingover.Tabby-Extension")
        
    }
}
