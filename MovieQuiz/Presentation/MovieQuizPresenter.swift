//
// Created by Ruslan S. Shvetsov on 26.02.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?

    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private let viewController: MovieQuizViewControllerProtocol?

    init(viewController: MovieQuizViewControllerProtocol = MovieQuizViewController()) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func isNotLastQuestion() -> Bool {
        currentQuestionIndex + 1 < questionsAmount
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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

    func yesButtonClicked(completion: @escaping () -> Void) {
        didAnswer(isYes: true, completion: completion)
    }

    func noButtonClicked(completion: @escaping () -> Void) {
        didAnswer(isYes: false, completion: completion)
    }

    func didAnswer(isCorrectAnswer: Bool) {
        correctAnswers += isCorrectAnswer ? 1 : 0
    }

    private func didAnswer(isYes: Bool, completion: @escaping () -> Void) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = isYes ? currentQuestion.correctAnswer : !currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: isCorrect, completion: completion)
    }

    private func proceedWithAnswer(isCorrect: Bool, completion: @escaping () -> Void) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.generateAnswerFeedback(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.proceedToNextQuestionOrResults()
            completion()
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            assertionFailure("no questions")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func proceedToNextQuestionOrResults() {
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

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: getQuestionsAmount())
        let bestGame = statisticService.bestGame
        let messageText = """
                          \nКоличество сыгранных квизов: \(statisticService.gamesCount)
                          Рекорд: \(bestGame.correct)/\(getQuestionsAmount()) (\(bestGame.date.dateTimeString))
                          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                          """
        return messageText
    }
}
