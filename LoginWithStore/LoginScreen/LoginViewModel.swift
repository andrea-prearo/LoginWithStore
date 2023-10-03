//
//  LoginViewModel.swift
//  LoginWithStore
//
//  Created by Andrea Prearo on 9/24/23.
//

import Combine
import SwiftUI

class LoginViewModel: ObservableObject {
    @Environment(\.isUserLoggedIn) private var isUserLoggedIn

    @Published var username = ""
    @Published var password = ""
    @Published var hasValidCredentials = false
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var error: LoginError?

    private var store: LoginStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: LoginStore) {
        self.store = store
        setupSubscriptions()
    }

    func authenticate() {
        store.send(.authenticate)
    }

    private func setupSubscriptions() {
        $username.sink { [weak self] username in
            guard let self else { return }
            self.store.send(.validateCredential(.username(username)))
        }
        .store(in: &cancellables)

        $password.sink { [weak self] password in
            guard let self else { return }
            self.store.send(.validateCredential(.password(password)))
        }
        .store(in: &cancellables)

        store.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
            guard let self else { return }
            self.hasValidCredentials = (state == .validCredentials)
            self.isLoading = (state == .authenticating)
            self.isAuthenticated = (state == .authenticated)
            if case let .error(error) = state {
                self.error = error
            } else {
                self.error = nil
            }
        }
        .store(in: &cancellables)
    }
}
