//
//  PeriodTWidgetExtensionLiveActivity.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  What the workout Live Activity looks like on the Lock Screen and in the
//  Dynamic Island. The app side that starts and updates it is
//  WorkoutLiveActivityController.
//

import ActivityKit
import WidgetKit
import SwiftUI

/// The Lock Screen shows the full card, and the Dynamic Island shows the logo and
/// how far through the program they are.
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    PeriodTLogo(size: 24)
                    Text("PeriodT")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("Workout in progress!")
                    .font(.headline)
                Text("You're at \(context.state.currentExerciseName)\(detailSuffix(context.state.detail))")
                Text("Never give up! Never what? 🗣️")
                    .font(.subheadline)
                ProgressDots(current: context.state.currentIndex, total: context.attributes.totalExercises)
                    .padding(.top, 4)
            }
            .padding()
            .environment(\.colorScheme, .light)
            .activityBackgroundTint(Color(white: 0.88))
            .activitySystemActionForegroundColor(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    PeriodTLogo(size: 28)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.currentIndex + 1)/\(context.attributes.totalExercises)")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.currentExerciseName)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressDots(current: context.state.currentIndex, total: context.attributes.totalExercises)
                }
            } compactLeading: {
                PeriodTLogo(size: 20)
            } compactTrailing: {
                Text("\(context.state.currentIndex + 1)/\(context.attributes.totalExercises)")
            } minimal: {
                PeriodTLogo(size: 20)
            }
            .keylineTint(WorkoutActivityColor.accent)
        }
    }

    private func detailSuffix(_ detail: String) -> String {
        detail.isEmpty ? "" : " - \(detail)"
    }
}

private enum WorkoutActivityColor {
    static let accent = Color(red: 0.86, green: 0.44, blue: 0.59)
}


private struct PeriodTLogo: View {
    let size: CGFloat

    var body: some View {
        Image("PeriodTLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

/// A dot per exercise joined by a line, filled in up to the current one.
struct ProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i <= current ? WorkoutActivityColor.accent : .clear)
                    .strokeBorder(i <= current ? WorkoutActivityColor.accent : .white, lineWidth: 4)
                    .frame(width: 22, height: 22)
                if i < total - 1 {
                    Rectangle()
                        .fill(i < current ? WorkoutActivityColor.accent : .clear)
                        .frame(height: 4)
                }
            }
        }
    }
}

extension WorkoutActivityAttributes {
    fileprivate static var preview: WorkoutActivityAttributes {
        WorkoutActivityAttributes(programName: "Day 1", totalExercises: 4)
    }
}

extension WorkoutActivityAttributes.ContentState {
    fileprivate static var first: Self {
        .init(currentExerciseName: "Goblet Squat", detail: "3 × 10", currentIndex: 0)
    }

    fileprivate static var third: Self {
        .init(currentExerciseName: "Rowing Machine", detail: "", currentIndex: 2)
    }
}

#Preview("Notification", as: .content, using: WorkoutActivityAttributes.preview) {
    WorkoutLiveActivity()
} contentStates: {
    WorkoutActivityAttributes.ContentState.first
    WorkoutActivityAttributes.ContentState.third
}
