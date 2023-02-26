import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

//    private var correctAnswers: Int = 0

    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private let presenter = MovieQuizPresenter()

    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let title: String = "Что-то пошло не так("
        //let message: String = "Невозможно загрузить данные"
        let buttonText: String = "Попробовать ещё раз"
        let alertModel = AlertModel(title: title, message: message, buttonText: buttonText) { [weak self] in
            guard let self else {
                return
            }
            self.presenter.restartGame()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.show(alert: alertModel)
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor(named: "YP Black (iOS)")?.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func show(quiz result: QuizResultsViewModel) {
        statisticService.store(correct: presenter.correctAnswers, total: presenter.getQuestionsAmount()) // presenter
        let bestGame = statisticService.bestGame
        let messageText = """
                          \nКоличество сыгранных квизов: \(statisticService.gamesCount)
                          Рекорд: \(bestGame.correct)/\(presenter.getQuestionsAmount()) (\(bestGame.date.dateTimeString))
                          Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                          """

        let alertModel = AlertModel(
                title: result.title,
                message: result.text + messageText,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.presenter.restartGame()
                    self.questionFactory?.requestNextQuestion()
                })
        alertPresenter?.show(alert: alertModel)
    }

    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ?
                UIColor(named: "YP Green (iOS)")?.cgColor :
                UIColor(named: "YP Red (iOS)")?.cgColor
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenter(viewController: self)
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
