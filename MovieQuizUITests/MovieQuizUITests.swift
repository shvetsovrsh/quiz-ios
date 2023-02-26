//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Ruslan S. Shvetsov on 24.02.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPoster, secondPoster)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPoster, secondPoster)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testGameFinish() {
        sleep(2)
        let buttons: [String] = ["Yes", "No"]
        for _ in 0...9 {
            let button = buttons.randomElement() ?? "Yes"
            app.buttons[button].tap()
            sleep(2)
        }
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists)
        let alertLabel = alert.label
        let buttonLabel = alert.buttons.firstMatch.label

        XCTAssertEqual(alertLabel, "Этот раунд окончен!")
        XCTAssertEqual(buttonLabel, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        sleep(2)
        let buttons: [String] = ["Yes", "No"]
        for _ in 0...9 {
            let button = buttons.randomElement() ?? "Yes"
            app.buttons[button].tap()
            sleep(2)
        }
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()

        sleep(2)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
        XCTAssertFalse(alert.exists)
    }
}
