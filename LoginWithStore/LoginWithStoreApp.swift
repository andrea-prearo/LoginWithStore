//
//  LoginWithStoreApp.swift
//  LoginWithStore
//
//  Created by Andrea Prearo on 9/24/23.
//

import SwiftUI

@main
struct LoginWithStoreApp: App {
    @State private var isUserLoggedIn = false

    var body: some Scene {
        WindowGroup {
            LandingView()
                .isUserLoggedIn($isUserLoggedIn)
        }
    }
}
