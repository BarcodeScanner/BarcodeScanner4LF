//
//  BarcodeScannerUITests.swift
//  BarcodeScannerUITests
//
//  Created by Crina Ciobotaru on 06.04.2023.
//

import XCTest

final class BarcodeScannerUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()
        
        

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func createAccount() throws {
        app.launch()
        let email = app.textFields["email-text-field"]
        email.tap()
        email.typeText("leca@unitbv.ro")
        
        let password = app.textFields["password-text-field"]
        password.tap()
        password.typeText("lecabv")
        
        app.buttons["create-account-button"].tap()
        XCTAssert(app.switches["inventory-switch"].waitForExistence(timeout: (30)))
    }
    

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
