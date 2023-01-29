//
// Created by Ruslan S. Shvetsov on 29.01.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isNotRecordAnymore(for gameRecord: GameRecord) -> Bool {
        correct < gameRecord.correct
    }
}