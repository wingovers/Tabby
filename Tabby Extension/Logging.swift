//
//  Logging.swift
//  Tabby the Copycat
//
//  Created by Ryan on 10/30/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation

func nowInSeconds() -> Int {
    let now = Calendar.current.dateComponents([.second], from: Date())
    return now.second!
}
