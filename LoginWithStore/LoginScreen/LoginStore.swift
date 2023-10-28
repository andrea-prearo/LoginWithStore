//
//  LoginFSM.swift
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
    case validateCredential(LoginCredential)
    case authenticate
    case ackError

    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool {
        switch (lhs, rhs) {
        case (.validateCredential(let credential1), .validateCredential(let credential2)):
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

    func reduce(state: LoginState, action: LoginAction) async -> LoginState {
        let hasActiveError = {
            if case .failure(_) = state {
                return true
            }
            return false
        }()

        var newState = state

        switch action {
        case .validateCredential(let credential):
            switch credential {
            case .username(let value):
                hasValidUsername = validateUsername(value)
                if !hasActiveError {
                    if hasValidCredentials {
                        newState = .validCredentials
                    } else {
                        newState = .validatingCredentials
                    }
                }
            case .password(let value):
                hasValidPassword = validatePassword(value)
                if !hasActiveError {
                    if hasValidCredentials {
                        newState = .validCredentials
                    } else {
                        newState = .validatingCredentials
                    }
                }
            }
        case .authenticate:
            newState = .authenticating
            // Simulate network call
            // since we're not using a real
            // authentication service
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.state.send(.authenticated)
                }
            }
        case .ackError:
            newState = .validCredentials
        }
        return newState
    }


    private func validateUsername(_ value: String) -> Bool {
        return value.count >= 8
    }

    private func validatePassword(_ value: String) -> Bool {
        return value.count >= 8
    }
}
