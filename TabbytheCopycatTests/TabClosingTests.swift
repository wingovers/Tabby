//
//  TabbytheCopycatTests.swift
//  TabbytheCopycatTests
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import XCTest

class TabbytheCopycat_TabClosing_Tests: XCTestCase {

    // UNFORTUNATELY MOCKING REQUIRES COPYING INTERNAL CODE OF CLASS
    fileprivate func makeSut() -> MockedTabCloser {
        MockedTabCloser()
    }

    func test_closesRightmostDuplicateTabs() throws {
        let sut = makeSut()
        let test = setupBasicTabClosingTest()

        sut.duplicates(in: test.testCases)
        wait(for: [test.asyncExpectation], timeout: 1)
        let results = test.testCases.map { $0.didClose }
        print(results)
        XCTAssertEqual(results, test.expectations)
    }

    func test_closesRightmostDuplicateTabs_ignoringNilPagesAndProperties() throws {
        let sut = makeSut()
        let test = setupNilIgnoringTabClosingTest()

        sut.duplicates(in: test.testCases)
        wait(for: [test.asyncExpectation], timeout: 1)
        let results = test.testCases.map { $0.didClose }
        print(results)
        XCTAssertEqual(results, test.expectations)
    }
}

fileprivate
struct TabClosingTest {
    let testCases: [SFSafariTab]
    let expectations: [Bool]
    let asyncExpectation: XCTestExpectation
}

fileprivate
extension TabbytheCopycat_TabClosing_Tests {
    func setupBasicTabClosingTest() -> TabClosingTest {
        let tab0 = setupTestCase(url: URLs.one.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab1 = setupTestCase(url: URLs.one.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab2 = setupTestCase(url: URLs.two.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab3 = setupTestCase(url: URLs.three.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab4 = setupTestCase(url: URLs.two.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)

        let testCases = Array(arrayLiteral: tab0, tab1, tab2, tab3, tab4)
        let expectations = [false, true, false, false, true]

        let asyncExpectation = XCTestExpectation(description: "Async tab closing takes 1 second")
        asyncExpectation.isInverted = true


        return TabClosingTest(testCases: testCases,
                              expectations: expectations,
                              asyncExpectation: asyncExpectation)
    }

    func setupNilIgnoringTabClosingTest() -> TabClosingTest {
        let tab0 = setupTestCase(url: URLs.one.url,
                                 isActive: true,
                                 hasProps: false,
                                 hasPage: true)
        let tab1 = setupTestCase(url: URLs.one.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: false)
        let tab2 = setupTestCase(url: URLs.two.url,
                                 isActive: false,
                                 hasProps: true,
                                 hasPage: true)
        let tab3 = setupTestCase(url: URLs.three.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab4 = setupTestCase(url: URLs.two.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)
        let tab5 = setupTestCase(url: URLs.three.url,
                                 isActive: true,
                                 hasProps: true,
                                 hasPage: true)

        let testCases = Array(arrayLiteral: tab0, tab1, tab2, tab3, tab4, tab5)
        let expectations = [false, false, false, false, false, true]

        let asyncExpectation = XCTestExpectation(description: "Async tab closing takes 1 second")
        asyncExpectation.isInverted = true


        return TabClosingTest(testCases: testCases,
                              expectations: expectations,
                              asyncExpectation: asyncExpectation)
    }

     func setupTestCase(url: URL?, isActive: Bool, hasProps: Bool, hasPage: Bool) -> SFSafariTab {
        let props = SFSafariProperties(url: url, isActive: isActive)
        let page = SFSafariPage(props: hasProps ? props : nil)
        return SFSafariTab(page: hasPage ? page : nil)
    }

    enum URLs: String {
        case one = "http://www.one.com"
        case two = "http://www.two.com"
        case three = "http://www.three.com"

        var url: URL {
            switch self {
                case .one: return URL(string: self.rawValue)!
                case .two: return URL(string: self.rawValue)!
                case .three: return URL(string: self.rawValue)!
            }
        }
    }
}

fileprivate
class SFSafariTab {
    internal init(page: SFSafariPage?) {
        self.page = page
    }

    let page: SFSafariPage?
    var didClose = false

    func getActivePage(completion: @escaping (SFSafariPage?) -> Void) {
        completion(page)
    }

    func close() {
        didClose = true
    }
}

fileprivate
struct SFSafariPage {
    let props: SFSafariProperties?
    func getPropertiesWithCompletionHandler(completion: @escaping (SFSafariProperties?) -> Void) {
        completion(props)
    }
}

fileprivate
struct SFSafariProperties {
    let url: URL?
    let isActive: Bool
}

fileprivate
class MockedTabCloser {
    func duplicates(in tabs: [SFSafariTab]) {
        var uniqueURLs = Set<String>()

        tabs.forEach { tab in
            tab.getActivePage { page in
                page?.getPropertiesWithCompletionHandler { props in
                    guard let props = props,
                          props.isActive,
                          let url = props.url?.absoluteString
                    else { return }
                    if uniqueURLs.contains(url) {
                        DispatchQueue.main.async {
                            tab.close()
                        }
                    } else {
                        uniqueURLs.insert(url)
                    }
                }
            }
        }
    }
}
