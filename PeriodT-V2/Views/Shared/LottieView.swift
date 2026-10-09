//
//  LottieView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI
import Lottie

/// SwiftUI wrapper around a bundled Lottie JSON animation.
/// Plays once from the start and calls `onFinished` when it ends.
struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var speed: CGFloat = 1
    var onFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.contentMode = .scaleAspectFit
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.backgroundBehavior = .pauseAndRestore
        view.play { finished in
            if finished { onFinished?() }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
