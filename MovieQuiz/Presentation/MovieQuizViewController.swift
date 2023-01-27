import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),


        QuizQuestion(image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),


        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),


        QuizQuestion(image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),


        QuizQuestion(image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
    ]

    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor(named: "YP Black (iOS)")?.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [self] _ in
            currentQuestionIndex = 0
            correctAnswers = 0
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
        alert.addAction(action)
        present(alert, animated: false, completion: nil)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }

    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = isCorrect ?
                UIColor(named: "YP Green (iOS)")?.cgColor :
                UIColor(named: "YP Red (iOS)")?.cgColor
        correctAnswers += isCorrect ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: showNextQuestionOrResults)
    }

    private func showNextQuestionOrResults() {
        guard currentQuestionIndex + 1 < questions.count else {
            let result = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат: \(correctAnswers) из 10",
                    buttonText: "Сыграть ещё раз")
            show(quiz: result)
            return
        }
        currentQuestionIndex += 1
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }

    override func viewDidLoad() {
        guard let first = questions.first else {
            fatalError("no questions")
        }
        show(quiz: convert(model: first))
        super.viewDidLoad()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
    }
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}
