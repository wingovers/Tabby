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
    @IBOutlet weak var buttonCommandLabel: NSTextField!
    @IBOutlet weak var openSafariExtensionPreferences: NSButton!
    @IBOutlet weak var catalinaBugLabel: NSTextField!
    @IBOutlet weak var winkBGImage: NSImageView!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Transparency theme for the install window
        view.wantsLayer = true
        let bgImage = NSImage(named: "Install")
        self.view.layer!.contents = bgImage
        view.window?.backgroundColor = .clear
        view.window?.isOpaque = false
        view.window?.isMovableByWindowBackground = true
        
    }
    
    // Strings
    let buttonCommandLabelBase = "To install, enable Tabby\u{2028} in Safari Preferences."
    let buttonCommandLabelInstalled = "Your Tabby is now installed!"
    let rightClickHeadlineLabelBase = "Right click to close duplicate tabs"
    let rightClickCopyLabelBase:String = "or copy links for\u{2028}  – that page\u{2028}  – tabs to the right or left"
    let toolbarTapHeadlineLabelBase = "Tap the toolbar cat\u{2028}to copy links for all tabs"
    let openSafariButtonBase = "Open Safari Preferences"
    let catalinaWarning = "If the install checkbox is unresponsive, try wiggling the window.\nThis sporadic bug affected all extensions starting March 2020."
    let catalinaPlaceholder = ""

    
    override func viewDidLoad() {
        
        // Start timer for install state label (buttonCommandLabel)
        timerForInstallChecks()
        
        // Check MacOS version and set install bug help tip for those affected
        showCatalinaBug()
        
        super.viewDidLoad()
        
        // Set labels
        self.toolbarTapHeadlineLabel.stringValue = toolbarTapHeadlineLabelBase
        self.rightClickHeadlineLabel.stringValue = rightClickHeadlineLabelBase
        self.rightClickCopyLabel.stringValue = rightClickCopyLabelBase
        self.buttonCommandLabel.stringValue = buttonCommandLabelBase
        self.openSafariExtensionPreferences.title = openSafariButtonBase
        
        // Winking Tabby cat in upper right corner
        winkBGImage.isHidden = true
        wink(1.8)
        wink(2.8)
        wink(9)
        
    }
    
    // Link to Safari Preferences
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "wingover.Tabby-Extension") { error in
            if let err = error {
                NSLog("Error \(String(describing: err))") }
        }
    }
    
    // Checks for MacOS version 10.15.3 where a sporadic bug appeared that makes the install checkbox unresponsive. One workaround is shaking the preferences pane to restore responsiveness. Jeff Johnson documented the bug: https://lapcatsoftware.com/articles/enable-extensions.html
    func showCatalinaBug() {
        let os = ProcessInfo().operatingSystemVersion
        print(os)
        guard os.majorVersion > 9, os.minorVersion > 14, os.patchVersion > 2 else { return }
        self.catalinaBugLabel.stringValue = self.catalinaWarning
    }
    
    // Fires about every second to show confirmation of intall state
    func timerForInstallChecks() {
        let timer = Timer(timeInterval: 1, repeats: true) { timer in
            self.getInstallState()
        }
        timer.tolerance = 1
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // Checks whether this extension is installed, setting a label in response, and hiding the Catalina bug tip if installation is successful
    func getInstallState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "wingover.Tabby-Extension") { (state, error) in
            DispatchQueue.main.async {
                guard state?.isEnabled ?? true else {
                    self.buttonCommandLabel.stringValue = self.buttonCommandLabelBase
                    self.catalinaBugLabel.isHidden = false
                    return
                }
                self.buttonCommandLabel.stringValue = self.buttonCommandLabelInstalled
                self.catalinaBugLabel.isHidden = true
                return
            }
        }
        
    }
    
    func wink(_ after: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(after*1000))) {
            // Wink
            self.winkBGImage.isHidden = false
            // Unwink
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                self.winkBGImage.isHidden = true
            }
            
        }
    }
    
}
