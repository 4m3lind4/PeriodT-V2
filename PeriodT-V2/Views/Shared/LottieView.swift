//
//  LottieView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  Wraps a Lottie animation so SwiftUI can use it. Used for the celebration
//  when an athlete finishes a program.
//

import SwiftUI
import Lottie

/// Plays once from the start and calls `onFinished` when it's done.
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
        // Let SwiftUI's .frame size it, otherwise it insists on the animation file's own size.
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.play { finished in
            if finished { onFinished?() }
        }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
