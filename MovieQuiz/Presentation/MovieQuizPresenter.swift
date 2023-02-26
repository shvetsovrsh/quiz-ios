//
// Created by Ruslan S. Shvetsov on 26.02.2023.
//

import UIKit

final class MovieQuizPresenter {

    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?

    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?


    func isNotLastQuestion() -> Bool {
        currentQuestionIndex + 1 < questionsAmount
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    func getQuestionsAmount() -> Int {
        questionsAmount
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += isCorrectAnswer ? 1 : 0
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect)
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            fatalError("no questions")
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func showNextQuestionOrResults() {
        guard isNotLastQuestion() else {
            let result = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат: \(correctAnswers) из 10",
                    buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: result)
            return
        }
        switchToNextQuestion()
        questionFactory?.requestNextQuestion()
    }

}
