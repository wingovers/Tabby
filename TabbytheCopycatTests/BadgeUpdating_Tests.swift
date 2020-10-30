//
//  TabbytheCopycat_BadgeUpdating_Tests.swift
//  TabbytheCopycatTests
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import XCTest

class TabbytheCopycat_BadgeUpdating_Tests: XCTestCase {

    // UNFORTUNATELY MOCKING REQUIRES COPYING INTERNAL CODE OF CLASS
    fileprivate func makeSut() -> MockedBadgeAgent {
        MockedBadgeAgent()
    }

    func test_badgesUpdatedForKnownWindow() throws {
        let sut = makeSut()
        let mockWindow = SFSafariWindow()
        let testBadgeUpdateInputs = [1, 2, 3]
        let expectations = expectedResultsOf(testBadgeUpdateInputs)

        testBadgeUpdateInputs.forEach { testValue in
            sut.update(mockWindow, with: testValue)
        }
        wait(for: [expectations.wait], timeout: 3)

        XCTAssertEqual(mockWindow.toolbar?.badgeHistory, expectations.badges)
        XCTAssertEqual(mockWindow.toolbar?.imageHistory, expectations.images)
    }

    func test_badgesUpdatedForUnknownWindow() throws {
        let sut = makeSut()
        let mockPage = SFSafariPage()
        let testBadgeUpdateInputs = [1, 2, 3]
        let expectations = expectedResultsOf(testBadgeUpdateInputs)

        testBadgeUpdateInputs.forEach { testValue in
            sut.updateWindow(of: mockPage, with: testValue)
        }
        wait(for: [expectations.wait], timeout: 3)

        XCTAssertEqual(mockPage.tab.window.toolbar?.badgeHistory,
                       expectations.badges)
        XCTAssertEqual(mockPage.tab.window.toolbar?.imageHistory,
                       expectations.images)
    }
}

extension TabbytheCopycat_BadgeUpdating_Tests {
    func expectedResultsOf(_ testValues: [Int]) -> Expected {
        var badges: [String?] = testValues.map { String($0) }
        var images: [String?] = Array(repeating: nil, count: testValues.count)
        let resetsToNormalState: [String?]  = Array(repeating: nil, count: testValues.count)
        badges.append(contentsOf: resetsToNormalState)
        images.append(contentsOf: resetsToNormalState)
        return Expected(badges: badges, images: images)
    }

    struct Expected {
        let badges: [String?]
        let images: [String?]

        var wait: XCTestExpectation {
            let expectation = XCTestExpectation(description: "Change badge text and image within 2 seconds")
            expectation.isInverted = true
            return expectation
        }
    }
}

// MARK: - STUBS IN LIEU OF MOCKING FRAMEWORK

fileprivate class SFSafariWindow {
    var toolbar: SFSafariToolbar? = SFSafariToolbar()

    func getToolbarItem(completion: @escaping (SFSafariToolbar?) -> Void) {
        completion(toolbar)
    }
}

fileprivate class SFSafariToolbar {
    var imageHistory = [String?]()
    var badgeHistory = [String?]()

    func setImage(_ image: NSImage?) {
        if image != nil {
            imageHistory.append(nil) // How do I get NSImage name + access usual bundle?
        } else {
            imageHistory.append(nil)
        }
    }

    func setBadgeText(_ string: String?) {
        badgeHistory.append(string)
    }
}

fileprivate class SFSafariTab {
    var window = SFSafariWindow()

    func getContainingWindow(completion: @escaping (SFSafariWindow?) -> Void) {
        completion(window)
    }
}

fileprivate class SFSafariPage {
    var tab = SFSafariTab()

    func getContainingTab(completion: @escaping (SFSafariTab) -> Void) {
        completion(tab)
    }
}

// MARK: - MOCK IN LIEU OF MOCKING FRAMEWORK

fileprivate class MockedBadgeAgent {
    private let wink = NSImage(named: "ToolbarItemIconCopied.pdf")
    private let unwink: NSImage? = nil
    private let winkingDuration = 0.3
    private let delayUntilReset = 1.5

    func update(_ window: SFSafariWindow, with count: Int) {
        window.getToolbarItem { [self] toolbar in
            toolbar?.setImage(wink)

            DispatchQueue.main.asyncAfter(deadline: .now() + winkingDuration) {
                toolbar?.setImage(unwink)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + winkingDuration) {
                toolbar?.setBadgeText(String(count))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delayUntilReset) {
                toolbar?.setBadgeText(nil)
            }
        }
    }

    func updateWindow(of page: SFSafariPage, with count: Int) {
        page.getContainingTab { tab in
            tab.getContainingWindow { [self] window in
                guard let window = window else { return }
                update(window, with: count)
            }
        }
    }
}
