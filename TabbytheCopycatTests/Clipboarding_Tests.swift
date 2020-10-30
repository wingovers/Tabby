//
//  TabbytheCopycat_Clipboarding_Tests.swift
//  TabbytheCopycatTests
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import XCTest

class TabbytheCopycat_Clipboarding_Tests: XCTestCase {
    func makeSut() -> Clipboarding {
        ClipboardAgent()
    }

    func test_linkFormatsPastedToClipboard() throws {
        let sut = makeSut()
        let testInput = LinkResults(plain: ["Plain1", "Plain2"],
                                    html: ["HTML1", "HTML2"])

        NSPasteboard.general.clearContents()
        sut.copy(testInput)
        let results = NSPasteboardContents()

        let expectedHTML = testInput.html.flattenedAsHTML()
        let expectedPlain = testInput.plain.flattenedAsPlain()

        XCTAssertEqual(results.htmlStrings.first!, expectedHTML)
        XCTAssertEqual(results.plainStrings.first!, expectedPlain)
        XCTAssertEqual(results.plainStrings.count, 1)
    }

}

struct NSPasteboardContents {
    init() {
        let items = NSPasteboard.general.pasteboardItems
        var htmlStrings = [String]()
        var plainStrings = [String]()
        items?.forEach {
            htmlStrings.append($0.string(forType: .html) ?? "Error: No HTML String Found")
            plainStrings.append($0.string(forType: .string) ?? "Error: No Plain String Found")
        }
        self.htmlStrings = htmlStrings
        self.plainStrings = plainStrings
    }

    var htmlStrings: [String]
    var plainStrings: [String]
}

extension Array where Element == String {
    func flattenedAsHTML() -> String {
        return self.joined(separator: "\n")
    }

    func flattenedAsPlain() -> String {
        return self.joined(separator: "\n\n")
            .appending("\n")
    }
}
