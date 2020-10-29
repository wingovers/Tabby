//
//  ViewController.swift
//  Tabby the Copycat
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Ryan Ferrell. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication
import SafariServices.SFSafariExtensionManager

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
        continuouslyCheckForSafariExtensionInstallState()
        populateTextFields()
        animateWinkingCat()
        super.viewDidLoad()
    }

    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: Identifiers.safariExtension.rawValue) { error in
            if let err = error {
                NSLog("Error \(String(describing: err))") }
        }
    }
}

private extension ViewController {
    func setupTransparentWindowBackground() {
        view.wantsLayer = true
        let bgImage = NSImage(named: ImageAssets.install.rawValue)
        view.layer?.contents = bgImage
        view.window?.backgroundColor = .clear
        view.window?.isOpaque = false
        view.window?.isMovableByWindowBackground = true
    }

    func populateTextFields() {
        toolbarTapHeadlineLabel.stringValue = Strings.toolbarTapHeadlineLabelBase.english
        rightClickHeadlineLabel.stringValue = Strings.rightClickHeadlineLabelBase.english
        rightClickCopyLabel.stringValue = Strings.rightClickCopyLabelBase.english
        buttonCommandLabel.stringValue = Strings.buttonCommandLabelBase.english
        openSafariExtensionPreferences.title = Strings.openSafariButtonBase.english
        privacyLabel.stringValue = Strings.privacyStatment.english
        displayWarningForCatalinaBug()
    }

    // Checks for MacOS version 10.15.3+ A sporadic bug was introduced that can make the install checkbox unresponsive. One workaround is shaking the preferences pane to restore responsiveness. Jeff Johnson documented the bug: https://lapcatsoftware.com/articles/enable-extensions.html
    func displayWarningForCatalinaBug() {
        let os = ProcessInfo().operatingSystemVersion
        guard os.majorVersion > 9, os.minorVersion > 14, os.patchVersion > 2 else { return }
        catalinaBugLabel.stringValue = Strings.catalinaWarning.english
    }

    func continuouslyCheckForSafariExtensionInstallState() {
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateLabelsWithSafariExtensionInstallState()
        }
        timer.tolerance = 1
        RunLoop.current.add(timer, forMode: .common)
    }

    func updateLabelsWithSafariExtensionInstallState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: Identifiers.safariExtension.rawValue) { (state, error) in
            DispatchQueue.main.async { [weak self] in
                guard state?.isEnabled ?? true else {
                    self?.buttonCommandLabel.stringValue = Strings.buttonCommandLabelBase.english
                    self?.catalinaBugLabel.isHidden = false
                    return
                }
                self?.buttonCommandLabel.stringValue = Strings.buttonCommandLabelInstalled.english
                self?.catalinaBugLabel.isHidden = true
                return
            }
        }
    }

    func animateWinkingCat() {
        winkBGImage.isHidden = true
        wink(1.8)
        wink(2.8)
        wink(9)
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
