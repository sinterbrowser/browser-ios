/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit
import UIKit

class ToolbarTests: KIFTestCase, UITextFieldDelegate {
    private var webRoot: String!

    override func setUp() {
        webRoot = SimplePageServer.start()
    }

    /**
     * Tests landscape page navigation enablement with the URL bar with tab switching.
     */
    func testLandscapeNavigationWithTabSwitch() {
        let previousOrientation = UIDevice.currentDevice().valueForKey("orientation") as! Int

        // Rotate to landscape.
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")

        tester().tapViewWithAccessibilityIdentifier("url")
        let textView = tester().waitForViewWithAccessibilityLabel("Address and Search") as! UITextField
        XCTAssertTrue(textView.text.isEmpty, "Text is empty")
        XCTAssertNotNil(textView.placeholder, "Text view has a placeholder to show when it's empty")

        // Navigate to two pages and press back once so that all buttons are enabled in landscape mode.
        let url1 = "\(webRoot)/numberedPage.html?page=1"
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url1)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        tester().tapViewWithAccessibilityIdentifier("url")
        let textView2 = tester().waitForViewWithAccessibilityLabel("Address and Search") as! UITextField
        XCTAssertEqual(textView2.text, url1, "Text is url")

        let url2 = "\(webRoot)/numberedPage.html?page=2"
        tester().clearTextFromAndThenEnterTextIntoCurrentFirstResponder("\(url2)\n")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 2")

        tester().tapViewWithAccessibilityLabel("Back")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        // Open new tab and then go back to previous tab to test navigation buttons.
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        let addTabButton = tester().waitForViewWithAccessibilityLabel("Add Tab") as! UIButton
        addTabButton.tap()
        tester().waitForViewWithAccessibilityLabel("Web content")

        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().tapViewWithAccessibilityLabel("Page 1")
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        // Test to see if all the buttons are enabled then close tab.
        tester().waitForTappableViewWithAccessibilityLabel("Back")
        tester().waitForTappableViewWithAccessibilityLabel("Forward")
        tester().waitForTappableViewWithAccessibilityLabel("Reload")
        tester().waitForTappableViewWithAccessibilityLabel("Share")
        tester().waitForTappableViewWithAccessibilityLabel("Bookmark")
        tester().tapViewWithAccessibilityLabel("Show Tabs")
        tester().swipeViewWithAccessibilityLabel("Page 1", inDirection: KIFSwipeDirection.Left)

        // Go Back to other tab to see if all buttons are disabled.
        tester().tapViewWithAccessibilityLabel("home")
        tester().waitForViewWithAccessibilityLabel("Web content")

        let back = tester().waitForViewWithAccessibilityLabel("Back") as! UIButton
        let forward = tester().waitForViewWithAccessibilityLabel("Forward") as! UIButton
        let reload = tester().waitForViewWithAccessibilityLabel("Reload") as! UIButton
        let share = tester().waitForViewWithAccessibilityLabel("Share") as! UIButton
        let bookmark = tester().waitForViewWithAccessibilityLabel("Bookmark") as! UIButton
        
        XCTAssertFalse(back.enabled, "Back button should be disabled")
        XCTAssertFalse(forward.enabled, "Forward button should be disabled")
        XCTAssertFalse(reload.enabled, "Reload button should be disabled")
        XCTAssertFalse(share.enabled, "Share button should be disabled")
        XCTAssertFalse(bookmark.enabled, "Bookmark button should be disabled")

        // Rotates back to previous orientation
        UIDevice.currentDevice().setValue(previousOrientation, forKey: "orientation")
    }

    func testURLEntry() {
        let textField = tester().waitForViewWithAccessibilityLabel("Address and Search") as! UITextField
        tester().tapViewWithAccessibilityIdentifier("url")
        tester().enterTextIntoCurrentFirstResponder("foobar")
        tester().tapViewWithAccessibilityLabel("Cancel")
        XCTAssertEqual(textField.text, "", "Verify that the URL bar text clears on about:home")

        let url = "\(webRoot)/numberedPage.html?page=1"

        // URL without "http://".
        let displayURL = "\(webRoot)/numberedPage.html?page=1".substringFromIndex(advance(url.startIndex, count("http://")))

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().enterTextIntoCurrentFirstResponder("\(url)\n")
        XCTAssertEqual(textField.text, displayURL, "URL matches page URL")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().enterTextIntoCurrentFirstResponder("foobar")
        tester().tapViewWithAccessibilityLabel("Cancel")
        XCTAssertEqual(textField.text, displayURL, "Verify that text reverts to page URL after entering text")

        tester().tapViewWithAccessibilityIdentifier("url")
        tester().clearTextFromFirstResponder()
        tester().tapViewWithAccessibilityLabel("Cancel")
        XCTAssertEqual(textField.text, displayURL, "Verify that text reverts to page URL after clearing text")
    }

    override func tearDown() {
        BrowserUtils.resetToAboutHome(tester())
    }
}
