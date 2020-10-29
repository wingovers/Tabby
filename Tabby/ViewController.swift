//
//  ViewController.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

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

enum Identifiers: String {
    case safariExtension = "wingover.Tabby.Extension"
}

enum ImageAssets: String {
    case install = "Install"
}

class ViewController: NSViewController {

    @IBOutlet weak var rightClickHeadlineLabel: NSTextField!
    @IBOutlet weak var rightClickCopyLabel: NSTextField!
    @IBOutlet weak var toolbarTapHeadlineLabel: NSTextField!
    @IBOutlet weak var buttonCommandLabel: NSTextField!
    @IBOutlet weak var openSafariExtensionPreferences: NSButton!
    @IBOutlet weak var catalinaBugLabel: NSTextField!
    @IBOutlet weak var winkBGImage: NSImageView!
    @IBOutlet weak var privacyLabel: NSTextField!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupTransparentWindowBackground()
    }
    
    override func viewDidLoad() {
        // Start timer for install state label (buttonCommandLabel)
        timerForInstallChecks()
        
        // Check MacOS version, set install bug help tip for those affected
        showCatalinaBug()
        
        super.viewDidLoad()
        
        // Set labels
        toolbarTapHeadlineLabel.stringValue = Strings.toolbarTapHeadlineLabelBase.english
        rightClickHeadlineLabel.stringValue = Strings.rightClickHeadlineLabelBase.english
        rightClickCopyLabel.stringValue = Strings.rightClickCopyLabelBase.english
        buttonCommandLabel.stringValue = Strings.buttonCommandLabelBase.english
        openSafariExtensionPreferences.title = Strings.openSafariButtonBase.english
        privacyLabel.stringValue = Strings.privacyStatment.english
        
        // Winking Tabby cat in upper right corner
        winkBGImage.isHidden = true
        wink(1.8)
        wink(2.8)
        wink(9)
        
    }
    
    // Link to Safari Preferences
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: Identifiers.safariExtension.rawValue) { error in
            if let err = error {
                NSLog("Error \(String(describing: err))") }
        }
    }

    func setupTransparentWindowBackground() {
        view.wantsLayer = true
        let bgImage = NSImage(named: ImageAssets.install.rawValue)
        self.view.layer!.contents = bgImage
        view.window?.backgroundColor = .clear
        view.window?.isOpaque = false
        view.window?.isMovableByWindowBackground = true
    }
    
    // Checks for MacOS version 10.15.3+ A sporadic bug was introduced that can make the install checkbox unresponsive. One workaround is shaking the preferences pane to restore responsiveness. Jeff Johnson documented the bug: https://lapcatsoftware.com/articles/enable-extensions.html
    func showCatalinaBug() {
        let os = ProcessInfo().operatingSystemVersion
        guard os.majorVersion > 9, os.minorVersion > 14, os.patchVersion > 2 else { return }
        self.catalinaBugLabel.stringValue = Strings.catalinaWarning.english
    }
    
    // Fires about every second to display confirmation of intall state
    func timerForInstallChecks() {
        let timer = Timer(timeInterval: 1, repeats: true) { timer in
            self.getInstallState()
        }
        timer.tolerance = 1
        RunLoop.current.add(timer, forMode: .common)
    }
    
    // Checks whether this extension is installed, setting a label in response, and hiding the Catalina bug tip if installation is successful
    func getInstallState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: Identifiers.safariExtension.rawValue) { (state, error) in
            DispatchQueue.main.async { [self] in
                guard state?.isEnabled ?? true else {
                    buttonCommandLabel.stringValue = Strings.buttonCommandLabelBase.english
                    catalinaBugLabel.isHidden = false
                    return
                }
                buttonCommandLabel.stringValue = Strings.buttonCommandLabelInstalled.english
                catalinaBugLabel.isHidden = true
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
