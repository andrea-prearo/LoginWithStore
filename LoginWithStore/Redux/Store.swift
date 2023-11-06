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
    func reduce(state: inout State, action: Action) -> SideEffect<Action>
}

extension Store {
    func send(_ action: Action) {
        let sideEffect = reduce(state: &state.value, action: action)
        switch sideEffect.operation {
        case .none:
            break
        case let .run(operation):
            Task {
                await operation(
                    Send { sideEffectAction in
                        self.send(sideEffectAction)
                    }
                )
            }
        }
    }
}

struct SideEffect<Action> {
    enum Operation {
        case none
        case run(@Sendable (_ send: Send<Action>) async -> Void)
    }

    let operation: Operation

    init(operation: Operation) {
      self.operation = operation
    }
}

extension SideEffect {
    static var none: Self {
      Self(operation: .none)
    }

    static func run(
      operation: @escaping @Sendable (_ send: Send<Action>) async -> Void
    ) -> Self {
        Self(operation: .run { send in
            await operation(send)
        })
    }
}

@MainActor
struct Send<Action>: Sendable {
    let send: @MainActor @Sendable (Action) -> Void

    init(send: @escaping @MainActor @Sendable (Action) -> Void) {
        self.send = send
    }
}
