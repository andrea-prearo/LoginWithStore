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

    var state: State { get set }
    func reduce(state: State, action: Action) -> State
}

extension Store {
    func send(_ action: Action) {
        state = reduce(state: state, action: action)
    }
}
