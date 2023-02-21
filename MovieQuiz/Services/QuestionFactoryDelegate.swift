//
// Created by Ruslan S. Shvetsov on 28.01.2023.
//

import Foundation

protocol QuestionFactoryDelegate : AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}