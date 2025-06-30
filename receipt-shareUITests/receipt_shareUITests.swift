//
//  receipt_shareUITests.swift
//  receipt-shareUITests
//
//  Created by 東　真史 on 2025/06/08.
//

import XCTest

final class receipt_shareUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // クリーンアップ処理
    }

    @MainActor
    func testBasicScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        
        app.launch()
        sleep(3) // アプリ起動完了まで待機
        
        // ログイン状態を確認して適切な処理を実行
        if isLoginScreenVisible(app) {
            // ログイン画面が表示されている場合
            snapshot("01_SignInScreen")
            performSimpleLogin(app: app)
        } else {
            // 既にログイン済みでホーム画面が表示されている場合
            print("Already logged in, skipping login screen")
        }
        
        addUIInterruptionMonitor(withDescription: "Alert", handler: { (alert) -> Bool in
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            if alert.buttons["パスワードを保存する"].exists {
                alert.buttons["パスワードを保存する"].tap()
                return true
            }
            if alert.buttons["今はしない"].exists {
                alert.buttons["今はしない"].tap()
                return true
            }
            return false
        })
        
        // メイン画面（Groups）
        snapshot("02_MainScreen")
        app.buttons["6/27買い出し"].tap() // グループをタップ
        sleep(2) // グループ詳細画面の読み込み待機
        snapshot("02_GroupDetailScreen")
        // レシート一覧をタプする
        app.buttons["Receipts"].tap()
        sleep(2) // レシート一覧の読み込み待機
        snapshot("02_ReceiptListScreen")
        
        // Scanタブ
        app.buttons["ScanTab"].tap()
        sleep(2) // タブ切り替え待機
        snapshot("03_ScanScreen")
        
        // Profileタブ
        app.buttons["ProfileTab"].tap()
        sleep(2) // タブ切り替え待機
        snapshot("04_ProfileScreen")
    }
    
    private func isLoginScreenVisible(_ app: XCUIApplication) -> Bool {
        // ログイン画面の特徴的な要素をチェック
        let emailField = app.textFields["メールアドレス"]
        let receiptShareTitle = app.staticTexts["Receipt Share"]
        let loginButton = app.buttons["ログイン"]
        
        // これらの要素のいずれかが存在すればログイン画面
        return emailField.waitForExistence(timeout: 3) || 
               receiptShareTitle.waitForExistence(timeout: 3) || 
               loginButton.waitForExistence(timeout: 3)
    }
    
    private func performSimpleLogin(app: XCUIApplication) {
        // メール入力
        let emailField = app.textFields["メールアドレス"]
        if emailField.waitForExistence(timeout: 5) {
            emailField.tap()
            emailField.typeText("tanaka@gmail.com")
        }
        
        // パスワード入力
        let passwordField = app.secureTextFields["パスワード"]
        if passwordField.waitForExistence(timeout: 5) {
            passwordField.tap()
            passwordField.typeText("password")
        }
        
        // ログインボタン
        let loginButton = app.buttons["ログイン"]
        if loginButton.waitForExistence(timeout: 5) && loginButton.isEnabled {
            loginButton.tap()
        }
        sleep(3)
    }
}
