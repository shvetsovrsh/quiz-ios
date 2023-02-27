//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Ruslan S. Shvetsov on 27.02.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {

    }

    func show(quiz result: QuizResultsViewModel) {

    }

    func highlightImageBorder(isCorrectAnswer: Bool) {

    }

    func showLoadingIndicator() {

    }

    func hideLoadingIndicator() {

    }

    func showNetworkError(message: String) {

    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let stub = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = stub.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
