//
//  SafariExtensionViewController.swift
//  Tabby Extension
//
//  Created by Ryan on 5/28/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
