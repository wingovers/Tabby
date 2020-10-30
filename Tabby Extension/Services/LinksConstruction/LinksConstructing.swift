//
//  LinkConstructing.swift
//  Tabby the Copycat Extension
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import Foundation

protocol LinksConstructing {
    func links(from input: [LinkConstructingInput]) -> LinkResults
}

typealias PlainTextLink = String
typealias HTMLLink = String


struct LinkResults {
    let plain: [PlainTextLink]
    let html: [HTMLLink]
    var count: Int { html.count }
}

struct LinkConstructingInput {
    let title: String?
    let url: URL?
}
