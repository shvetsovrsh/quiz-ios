//
// Created by Ruslan S. Shvetsov on 28.01.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    weak var delegate: MovieQuizViewController?

    init(delegate: MovieQuizViewController) {
        self.delegate = delegate
    }

    func show(alert: AlertModel) {
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: alert.buttonText, style: .default) { _ in
            alert.completion?()
        }
        alertController.addAction(alertAction)
        delegate?.present(alertController, animated: false, completion: nil)
    }
}
