//
//  DJHelperUITests.swift
//  DJHelperUITests
//
//  Created by Craig Swanson on 6/3/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import XCTest

class DJHelperUITests: XCTestCase {
    
    // Register with different password fields should present password alert
    // Register with empty text field should return nothing
    // Register with a unique username and matching passwords should present success alert
    // ...and continuing to sign in should present table view controller.

    let app = XCUIApplication()
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testInvalidLogIn() {

        // TODO: This test helped me to find an error!
        // We need to add an alert if the fetch request does not find the username in core data.

        let usernameTextField = app.textFields["HostSignIn.UsernameTextField"]
            usernameTextField.tap()
        usernameTextField.typeText("FakeUsername")

        let hostsigninPasswordtextfieldTextField = app.textFields["HostSignIn.PasswordTextField"]
        hostsigninPasswordtextfieldTextField.tap()
        hostsigninPasswordtextfieldTextField.typeText("password")
        app.staticTexts["Sign in"].tap()

        addUIInterruptionMonitor(withDescription: "System Dialog") { (alert) -> Bool in
            let invalidSignInText = "LogIn Error"
            if alert.label.contains(invalidSignInText) {
                XCTAssertTrue(alert.exists)
                alert.buttons["OK"].tap()
            } else {
                XCTFail()  // Want it to fail if it reaches this case
            }
            return true
        }
        app.tap()
    }

    func testShowRegisterScene() {

        app.staticTexts["Register"].tap()
        XCTAssertTrue(app.staticTexts["Create your Account"].exists)
    }

    func testRegisterUnmatchedPasswords() {

        app.staticTexts["Register"].tap()

        let usernameTextField = app.textFields["HostRegistration.UsernameTextField"]
            usernameTextField.tap()
        usernameTextField.typeText("plastic")

        let emailTextField = app.textFields["HostRegistration.EmailTextField"]
            emailTextField.tap()
        emailTextField.typeText("email@me.com")

        let passwordTextField = app.textFields["HostRegistration.PasswordTextField"]
            passwordTextField.tap()
        passwordTextField.typeText("first")

        let confirmTextField = app.textFields["HostRegistration.ConfirmTextField"]
            confirmTextField.tap()
        confirmTextField.typeText("second")

        app.staticTexts["Create Account"].tap()

        addUIInterruptionMonitor(withDescription: "System Dialog") { (alert) -> Bool in
            let invalidPasswordText = "Password Error"
            if alert.label.contains(invalidPasswordText) {
                XCTAssertTrue(alert.exists)
                alert.buttons["OK"].tap()
            } else {
                XCTFail()  // Want it to fail if it reaches this case
            }
            return true
        }
        app.tap()

    }
}
