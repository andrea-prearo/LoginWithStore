//
//  LoginStore.swift
//  LoginWithStore
//
//  Created by Andrea Prearo on 9/24/23.
//

import Combine
import Foundation

enum LoginError: Error, Equatable {
    case invalidCredentials
    case networkError(Error)

    static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials):
            return true
        case (.networkError(_), .networkError(_)):
            return true
        default:
            return false
        }
    }
}

enum LoginCredential {
    case username(String)
    case password(String)
}

enum LoginAction: Equatable {
    case enteringCredential(LoginCredential)
    case authenticate
    case authenticated
    case failure(LoginError)
    case ackError

    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        switch (lhs, rhs) {
        case (.enteringCredential(let credential1), .enteringCredential(let credential2)):
            switch (credential1, credential2) {
            case (.username, .username):
                return true
            case (.password, .password):
                return true
            default:
                return false
            }
        case (.authenticate, .authenticate):
            return true
        default:
            return false
        }
    }
}

enum LoginState: Equatable {
    case idle
    case validatingCredentials
    case validCredentials
    case authenticating
    case authenticated
    case failure(LoginError)

    static func == (lhs: LoginState, rhs: LoginState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.validatingCredentials, .validatingCredentials):
            return true
        case (.validCredentials, .validCredentials):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated, .authenticated):
            return true
        case (.failure(_), .failure(_)):
            return true
        default:
            return false
        }
    }
}

class LoginStore: Store {
    @Published var state: CurrentValueSubject<LoginState, Never> = .init(.idle)

    private var hasValidUsername = false
    private var hasValidPassword = false
    private var hasValidCredentials: Bool {
        return hasValidUsername && hasValidPassword
    }

    func reduce(state: inout LoginState, action: LoginAction) -> SideEffect<LoginAction> {
        let hasActiveError = {
            if case .failure(_) = state {
                return true
            }
            return false
        }()

        switch action {
        case .enteringCredential(let credential):
            switch credential {
            case .username(let value):
                hasValidUsername = validateUsername(value)
                if !hasActiveError {
                    if hasValidCredentials {
                        state = .validCredentials
                    } else {
                        state = .validatingCredentials
                    }
                }
                return .none
            case .password(let value):
                hasValidPassword = validatePassword(value)
                if !hasActiveError {
                    if hasValidCredentials {
                        state = .validCredentials
                    } else {
                        state = .validatingCredentials
                    }
                }
                return .none
            }
        case .authenticate:
            state = .authenticating
            return .run { operation in
                // Simulate network call
                // since we're not using a real
                // authentication service
                sleep(2)
                await operation.send(.authenticated)
            }
        case .authenticated:
            state = .authenticated
            return .none
        case .failure(let error):
            state = .failure(error)
            return .none
        case .ackError:
            state = .validCredentials
            return .none
        }
    }

    private func validateUsername(_ value: String) -> Bool {
        // Way too simple `username` validation
        // for illustration purposes only
        return value.count >= 8
    }

    private func validatePassword(_ value: String) -> Bool {
        // Way too simple `password` validation
        // for illustration purposes only
        return value.count >= 8
    }
}
