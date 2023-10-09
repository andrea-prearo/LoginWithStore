//
//  LoginStoreTests.swift
//  LoginWithStoreTests
//
//  Created by Andrea Prearo on 10/8/23.
//

import Combine
@testable import LoginWithStore
import XCTest

class LoginStoreTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    private let sut = LoginStore()

    func testSuccessfulLoginTransitions() {
        var expectedStateSequence: [LoginState] = [
            .idle,
            .validatingCredentials,
            .validCredentials,
            .authenticating,
            .authenticated
        ]
        var actualStateSequence: [LoginState] = []
        let expectation = expectation(description: "Successfully authenticated")
        expectation.expectedFulfillmentCount = 5

        sut.state.sink { state in
            actualStateSequence.append(state)
            expectation.fulfill()
        }.store(in: &cancellables)

        XCTAssertEqual(sut.state.value, .idle)
        sut.send(.enteringCredential(.username("some username")))
        sleep(1)
        sut.send(.enteringCredential(.password("some password")))
        sleep(1)
        sut.send(.authenticate)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(expectedStateSequence, actualStateSequence)
    }

    func testErrorAckTransition() {
        let expectation = expectation(description: "Successfully acknowledge error")
        expectation.isInverted = true

        XCTAssertEqual(sut.state.value, .idle)
        sut.state.value = .error(.invalidCredentials)
        XCTAssertEqual(sut.state.value, .error(.invalidCredentials))
        sut.send(.ackError)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state.value, .validCredentials)
    }
}
