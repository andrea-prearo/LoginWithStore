//
//  BackgroundBlurView.swift
//  LoginWithStore
//
//  Created by Andrea Prearo on 9/24/23.
//

import UIKit
import SwiftUI

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .black.withAlphaComponent(0.05)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
