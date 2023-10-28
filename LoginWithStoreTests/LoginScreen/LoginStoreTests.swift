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
        let expectedStateSequence: [LoginState] = [
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
        XCTAssertEqual(sut.state.value, .idle)
        sut.state.value = .failure(.invalidCredentials)
        XCTAssertEqual(sut.state.value, .failure(.invalidCredentials))
        sut.send(.ackError)
        sleep(1)
        XCTAssertEqual(sut.state.value, .validCredentials)
    }
}
