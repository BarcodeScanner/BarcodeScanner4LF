//
//  LoginBarcode.swift
//  BarcodeScannerUITests
//
//  Created by Crina Ciobotaru on 27.04.2023.
//

import XCTest

final class LoginBarcode: XCTestCase {
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
    
    func test1Login() throws {
        let email = app.textFields["Email"]
        email.tap()
        email.typeText("leca@unitbv.ro")
        
        let password = app.secureTextFields["Password"]
        password.tap()
        password.typeText("lecabv")
        app.keyboards.buttons["Done"].tap()
        
        app.buttons["Log In"].tap()
        XCTAssert(app.navigationBars["Inventory"].buttons["Log out"].waitForExistence(timeout: 15))
    }
    
    func test2CreateInventory() throws {
        let app = XCUIApplication()
        app.navigationBars["Inventory"].buttons["add"].tap()
        let name = app.textFields["Name"]
        name.tap()
        name.typeText("New Inventory")
        
        app.staticTexts["Create"].tap()
        app.alerts.scrollViews.otherElements.buttons["OK"].tap()
    }
    
    func test3AddProduct() throws {
        XCTAssert(app.tables.cells.element(boundBy: 6).waitForExistence(timeout: 10))
        app.tables.cells.element(boundBy: 6).tap()
        let newInventoryNavigationBar = app.navigationBars["New Inventory"]
        let addButton = newInventoryNavigationBar.buttons["add"]
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        addButton.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Reports"]/*[[".buttons[\"Reports\"].staticTexts[\"Reports\"]",".staticTexts[\"Reports\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Reports"].buttons["New Inventory"].tap()
        newInventoryNavigationBar.buttons["Inventory"].tap()
    }
}
