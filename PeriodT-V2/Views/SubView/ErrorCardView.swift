//
//  ErrorCardView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Pink error card used for every user-facing error in the app.
/// Presented by `.errorCardHost()`; screens don't build this directly.
struct ErrorCardView: View {
    let error: AppError
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(error.title)
                    .font(.system(size: 24, weight: .bold))
                Text(error.message)
                    .font(.system(size: 20))
            }
            .foregroundStyle(CoreColor.primary)

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(CoreColor.primary)
                    .padding(.top, 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CoreColor.ringBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Presentation

/// Injected by `.errorCardHost()`. Any child view can call
/// `presentError(.saveFailed(.journal))` and the nearest host shows the card.
struct PresentErrorKey: EnvironmentKey {
    static let defaultValue: (AppError) -> Void = { _ in }
}

extension EnvironmentValues {
    var presentError: (AppError) -> Void {
        get { self[PresentErrorKey.self] }
        set { self[PresentErrorKey.self] = newValue }
    }
}

/// Owns the currently shown error and overlays the card at the bottom of the
/// screen. Errors slide up, auto-dismiss after `dismissDelay` (unless the
/// error says otherwise), and a new error restarts the timer.
struct ErrorCardHost: ViewModifier {
    static let dismissDelay: Duration = .seconds(3)

    @State private var error: AppError?

    init(initial: AppError? = nil) {
        _error = State(initialValue: initial)
    }

    func body(content: Content) -> some View {
        content
            .environment(\.presentError) { newError in
                withAnimation { error = newError }
            }
            .overlay(alignment: .bottom) {
                if let error {
                    ErrorCardView(error: error) {
                        withAnimation { self.error = nil }
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: error) {
                        guard error.autoDismisses else { return }
                        try? await Task.sleep(for: Self.dismissDelay)
                        guard !Task.isCancelled else { return }
                        withAnimation { self.error = nil }
                    }
                }
            }
            .animation(.easeInOut, value: error)
    }
}

extension View {
    /// Makes this view (typically a whole screen or sheet) the place where
    /// errors raised by its children are shown. Pass `initial` to show an
    /// error as soon as the screen appears (e.g. a failed data store).
    func errorCardHost(initial: AppError? = nil) -> some View {
        modifier(ErrorCardHost(initial: initial))
    }
}

#Preview("Save failed") {
    ErrorCardView(error: .saveFailed(.workout)) {}
        .padding()
}

#Preview("Data unavailable") {
    ErrorCardView(error: .dataUnavailable) {}
        .padding()
}
