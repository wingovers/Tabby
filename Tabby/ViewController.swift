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

    @IBOutlet weak var winkBGImage: NSImageView!
    @IBOutlet weak var toolbarTapHeadlineLabel: NSTextField!
    @IBOutlet weak var toolbarTapResultLabel: NSTextField!
    @IBOutlet weak var rightClickHeadlineLabel: NSTextField!
    @IBOutlet weak var rightClickBullet1Label: NSTextField!
    @IBOutlet weak var rightClickBullet2Label: NSTextField!
    @IBOutlet weak var rightClickBullet3Label: NSTextField!
    @IBOutlet weak var enableTabbyInstructionsLabel: NSTextField!
    @IBOutlet weak var openSafariExtensionPreferences: NSButton!
    @IBOutlet weak var catalinaBugTitleLabel: NSTextField!
    @IBOutlet weak var catalinaBugWorkaroundLabel: NSTextField!
    @IBOutlet weak var catalinaBugButton: NSButton!
    @IBOutlet weak var privacyLabel: NSTextField!
    @IBOutlet weak var privacyLink: NSButton!

    
    
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

    @IBAction func openGithubRepo(_ sender: AnyObject?) {
        guard let github = URL(string: "https://www.github.com/wingovers/Tabby") else { return }
        NSWorkspace.shared.open([github],
                                withAppBundleIdentifier: "com.apple.safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
    }

    @IBAction func openBugLink(_ sender: AnyObject?) {
        guard let mjtsai = URL(string: "https://mjtsai.com/blog/2020/06/03/unable-to-enable-safari-extensions/") else { return }
        NSWorkspace.shared.open([mjtsai],
                                withAppBundleIdentifier: "com.apple.safari",
                                options: [],
                                additionalEventParamDescriptor: nil,
                                launchIdentifiers: nil)
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
        toolbarTapHeadlineLabel.stringValue = Strings.toolbarTapHeadline.english
        toolbarTapResultLabel.stringValue = bulleted(Strings.toolbarTapResult.english)
        rightClickHeadlineLabel.stringValue = Strings.rightClickHeadline.english
        rightClickBullet1Label.stringValue = bulleted(Strings.rightClickBullet1.english)
        rightClickBullet2Label.stringValue = bulleted(Strings.rightClickBullet2.english)
        rightClickBullet3Label.stringValue = bulleted(Strings.rightClickBullet3.english)
        enableTabbyInstructionsLabel.stringValue = Strings.enableTabbyInstructions.english
        openSafariExtensionPreferences.title = Strings.openSafariPreferences.english
        privacyLabel.stringValue = Strings.privacyStatment.english
        privacyLink.title = Strings.privacyLinkInvitation.english

        populateWarningForCatalinaBug(for: currentOS())
    }

    func currentOS() -> OperatingSystemVersion {
        ProcessInfo().operatingSystemVersion
    }

    // Checks for MacOS version 10.15.3+ A sporadic bug was introduced that can make the install checkbox unresponsive. One workaround is shaking the preferences pane to restore responsiveness. Jeff Johnson documented the bug: https://lapcatsoftware.com/articles/enable-extensions.html
    func populateWarningForCatalinaBug(for os: OperatingSystemVersion) {
        DispatchQueue.main.async { [self] in
            catalinaBugTitleLabel.stringValue = Strings.blank.english
            catalinaBugWorkaroundLabel.stringValue = Strings.blank.english
            catalinaBugButton.title = Strings.blank.english
            guard os.majorVersion == 10, os.minorVersion > 14, os.patchVersion > 2 else { return }
            catalinaBugTitleLabel.stringValue = Strings.catalinaBugTitle.english
            catalinaBugWorkaroundLabel.stringValue = Strings.catalinaWorkaround.english
            catalinaBugButton.title = Strings.catalinaBugLinkLabel.english
        }
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
                    self?.enableTabbyInstructionsLabel.stringValue = Strings.enableTabbyInstructions.english
                    self?.setCatalinaBugVisibility(to: true)
                    return
                }
                self?.enableTabbyInstructionsLabel.stringValue = Strings.installed.english
                self?.setCatalinaBugVisibility(to: false)
                return
            }
        }
    }

    func setCatalinaBugVisibility(to state: Bool) {
        catalinaBugTitleLabel.isHidden = !state
        catalinaBugWorkaroundLabel.isHidden = !state
        catalinaBugButton.isHidden = !state
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

    func bulleted(_ string: String) -> String {
        String(" – \(string)")
    }
}
