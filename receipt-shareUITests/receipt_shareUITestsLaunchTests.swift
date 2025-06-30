//
//  receipt_shareUITestsLaunchTests.swift
//  receipt-shareUITests
//
//  Created by 東　真史 on 2025/06/08.
//

import XCTest

final class receipt_shareUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // アプリが完全に起動するまで少し待機
        sleep(2)
        
        // ランチ画面のスクリーンショット
        snapshot("00_LaunchScreen")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
