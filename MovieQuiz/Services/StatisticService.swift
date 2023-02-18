//
// Created by Ruslan S. Shvetsov on 29.01.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var totalQuestions: Int { get set }
    var totalResult: Int { get set }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String, CaseIterable {
        case correct, total, bestGame, gamesCount
    }

    func store(correct count: Int, total amount: Int) {
        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.isNotRecordAnymore(for: currentRecord) {
            bestGame = currentRecord
        }

        totalQuestions += amount
        totalResult += count
        gamesCount += 1
    }

    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        return Double(correct * 100 / total)
    }

    var totalQuestions: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }

    var totalResult: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }

    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? PropertyListDecoder().decode(GameRecord.self, from: data)
            else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? PropertyListEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
