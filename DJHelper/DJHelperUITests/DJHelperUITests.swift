//
//  DJHelperUITests.swift
//  DJHelperUITests
//
//  Created by Craig Swanson on 6/7/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import XCTest

class DJHelperUITests: XCTestCase {

    // Login with invalid credentials should present alert
    // Login with valid credentials should transition to trable view controller
    // Tapping Register on Sign In scene should transition to Register scene
    // Register with different password fields should present password alert
    // Register with empty text field should return nothing
    // Register with a unique username and matching passwords should present success alert
    // ...and continuing to sign in should transition to table view controller.

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
                XCTFail("Programmed failure due to unanticipated events at Host Login")  // Want it to fail if it reaches this case
            }
            return true
        }
        app.tap()
    }

    func testValidHostLogIn() {

        let usernameTextField = app.textFields["HostSignIn.UsernameTextField"]
        usernameTextField.tap()
        usernameTextField.typeText("BMac")

        let hostsigninPasswordtextfieldTextField = app.textFields["HostSignIn.PasswordTextField"]
        hostsigninPasswordtextfieldTextField.tap()
        hostsigninPasswordtextfieldTextField.typeText("ciao")
        app.staticTexts["Sign in"].tap()

        let addNewEvent = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addNewEvent.exists)
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
                XCTFail("Programmed fail due to unanticipated password matching alert")  // Want it to fail if it reaches this case
            }
            return true
        }
        app.tap()
    }

    func testValidRegistrationAndSignIn() {

        app.staticTexts["Register"].tap()
        let fakeUser = String("\(Date())")

        let usernameTextField = app.textFields["HostRegistration.UsernameTextField"]
        usernameTextField.tap()
        usernameTextField.typeText(fakeUser)

        let emailTextField = app.textFields["HostRegistration.EmailTextField"]
        emailTextField.tap()
        emailTextField.typeText("radiohead@bandcamp.com")

        let passwordTextField = app.textFields["HostRegistration.PasswordTextField"]
        passwordTextField.tap()
        passwordTextField.typeText("trees")

        let confirmTextField = app.textFields["HostRegistration.ConfirmTextField"]
        confirmTextField.tap()
        confirmTextField.typeText("trees")

        app.staticTexts["Create Account"].tap()

        addUIInterruptionMonitor(withDescription: "System Dialog") { (alert) -> Bool in
            let validRegistrationTest = "Successful Registration"
            if alert.label.contains(validRegistrationTest) {
                XCTAssertTrue(alert.exists)
                alert.buttons["Sign In"].tap()
            } else {
                XCTFail("Programmed fail due to unanticipated registration/sign in alert")  // Want it to fail if it reaches this case
            }
            return true
        }

        app.tap()

        let addNewEvent = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addNewEvent.exists)
    }
}
