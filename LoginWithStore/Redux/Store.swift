//
//  Store.swift
//  LoginWithStore
//
//  Created by Andrea Prearo on 9/30/23.
//

import Combine
import Foundation

protocol Store: ObservableObject {
    associatedtype State
    associatedtype Action

    var state: CurrentValueSubject<State, Never> { get set }
    func reduce(state: State, action: Action) async -> State
}

extension Store {
    func send(_ action: Action) {
        Task {
            state.value = await reduce(state: state.value, action: action)
        }
    }
}
