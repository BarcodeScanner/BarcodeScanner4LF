//
//  BarcodeScannerUITestsLaunchTests.swift
//  BarcodeScannerUITests
//
//  Created by Crina Ciobotaru on 06.04.2023.
//

import XCTest 

final class BarcodeScannerUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    let app = XCUIApplication()
    static var launched = false
    
    override func setUp() {
        if !BarcodeScannerUITestsLaunchTests.launched {
            app.launch()
            BarcodeScannerUITestsLaunchTests.launched = true
        }
    }
    
    

}
