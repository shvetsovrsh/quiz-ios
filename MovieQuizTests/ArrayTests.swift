//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Ruslan S. Shvetsov on 23.02.2023.
//

import Foundation
import XCTest

@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [0, 1, 2, 3, 5]

        // When
        let value = array[safe: 2]

        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }

    func testGetValueOutOfRange() throws {
        // Given
        let array = [0, 1, 2, 3, 5]

        // When
        let value = array[safe: 20]

        // Then
        XCTAssertNil(value)
    }
}
