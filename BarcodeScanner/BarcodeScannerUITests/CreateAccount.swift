//
//  CreateAccount.swift
//  BarcodeScannerUITests
//
//  Created by Crina Ciobotaru on 27.04.2023.
//

import XCTest

final class CreateAccount: XCTestCase {
    
    let app = XCUIApplication()
    static var launched = false
    
    override func setUp() {
        if !LoginBarcode.launched {
            app.launch()
            LoginBarcode.launched = true
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateAccount() throws {
        let email = app.textFields["Email"]
        email.tap()
        email.typeText("deli@unitbv.ro")
        
        let password = app.secureTextFields["Password"]
        password.tap()
        password.typeText("delibv")
        app.keyboards.buttons["Done"].tap()
        
        app.buttons["Create Account"].tap()
        XCTAssert(app.navigationBars["Inventory"].buttons["Log out"].waitForExistence(timeout: 15))
    }
}
