//
//  TabbytheCopycatTests.swift
//  TabbytheCopycatTests
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import XCTest

class TabbytheCopycat_LinksConstructing_Tests: XCTestCase {
    func makeSut() -> LinksConstructing {
        LinksConstructor()
    }

    func test_makesValidLinks() throws {
        let sut = makeSut()
        let test0 = LinkTest(title: "xkcd",
                             url: URL(string: "https://xkcd.com"),
                             resultPlain: "xkcd\nxkcd.com",
                             resultHTML: "<p><a href=\"https://xkcd.com\">xkcd</a></p>")
        let test1 = LinkTest(title: "☺ ☻",
                             url: URL(string: "https://www.copypastecharacter.com"),
                             resultPlain: "☺ ☻\nwww.copypastecharacter.com",
                             resultHTML: "<p><a href=\"https://www.copypastecharacter.com\">&#x263A; &#x263B;</a></p>")

        let results = sut.links(from: [test0.input, test1.input])

        XCTAssertEqual(results.html[0], test0.resultHTML)
        XCTAssertEqual(results.html[1], test1.resultHTML)
        XCTAssertEqual(results.plain[0], test0.resultPlain)
        XCTAssertEqual(results.plain[1], test1.resultPlain)
    }

    func test_makesValidEmptyLinks() throws {
        let sut = makeSut()
        let test0 = LinkTest(title: "",
                             url: URL(string: ""),
                             resultPlain: validPlainLinkResult(),
                             resultHTML: validHTMLLinkResult())
        let test1 = LinkTest(title: nil,
                             url: nil,
                             resultPlain: validPlainLinkResult(),
                             resultHTML: validHTMLLinkResult())
        let test2 = LinkTest(title: nil,
                             url: URL(string: ""),
                             resultPlain: validPlainLinkResult(),
                             resultHTML: validHTMLLinkResult())
        let test3 = LinkTest(title: "",
                             url: nil,
                             resultPlain: validPlainLinkResult(),
                             resultHTML: validHTMLLinkResult())

        let results = sut.links(from: [test0.input, test1.input, test2.input, test3.input])

        XCTAssertEqual(results.html[0], test0.resultHTML)
        XCTAssertEqual(results.html[1], test1.resultHTML)
        XCTAssertEqual(results.html[2], test2.resultHTML)
        XCTAssertEqual(results.html[3], test3.resultHTML)
        XCTAssertEqual(results.plain[0], test0.resultPlain)
        XCTAssertEqual(results.plain[1], test1.resultPlain)
        XCTAssertEqual(results.plain[2], test2.resultPlain)
        XCTAssertEqual(results.plain[3], test3.resultPlain)
    }
}

extension TabbytheCopycat_LinksConstructing_Tests {
    func validPlainLinkResult() -> String {
        String("Untitled\nwww.google.com")
    }

    func validHTMLLinkResult() -> String {
        String("<p><a href=\"https://www.google.com\">Untitled</a></p>")
    }
}

struct LinkTest {
    let title: String?
    let url: URL?
    var input: LinkConstructingInput {
        LinkConstructingInput(title: title,
                              url: url)
    }
    let resultPlain: String
    let resultHTML: String
}
