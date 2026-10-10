//
//  ErrorCardView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  The pink error card and the plumbing to show it. Any view can call
//  `presentError(...)` from the environment and the nearest `.errorCardHost()`
//  slides the card up. I set it up this way so screens don't each need their own
//  error state and alert, and every error looks the same across the app.
//

import SwiftUI

/// Screens don't build this themselves, `.errorCardHost()` shows it.
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

/// Set by `.errorCardHost()`. Any child view can call `presentError(.saveFailed(.journal))`
/// and the nearest host shows the card. Outside a host it does nothing.
struct PresentErrorKey: EnvironmentKey {
    static let defaultValue: (AppError) -> Void = { _ in }
}

extension EnvironmentValues {
    var presentError: (AppError) -> Void {
        get { self[PresentErrorKey.self] }
        set { self[PresentErrorKey.self] = newValue }
    }
}

/// Holds whichever error is showing and overlays the card at the bottom of the screen.
/// Errors slide up and go away after `dismissDelay` (unless the error says to stay),
/// and a new error restarts the timer.
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
    /// Makes this view (usually a whole screen or sheet) the place where errors from
    /// anything inside it get shown. Pass `initial` to show one straight away.
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
