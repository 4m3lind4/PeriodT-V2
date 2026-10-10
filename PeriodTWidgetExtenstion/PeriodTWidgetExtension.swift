//
//  PeriodTWidgetExtension.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PeriodCountdownEntry {
        PeriodCountdownEntry(date: Date(), daysUntilPeriod: 7)
    }

    func getSnapshot(in context: Context, completion: @escaping (PeriodCountdownEntry) -> Void) {
        // The widget gallery shows sample data until the user has logged a period.
        let days = PeriodCountdownStore.daysUntilNextPeriod() ?? (context.isPreview ? 7 : nil)
        completion(PeriodCountdownEntry(date: Date(), daysUntilPeriod: days))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PeriodCountdownEntry>) -> Void) {
        // One entry per day for the next week, so the countdown ticks over at midnight
        // even if the app isn't opened. The app reloads the timeline when a new period is logged.
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entries = (0..<7).compactMap { offset -> PeriodCountdownEntry? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            return PeriodCountdownEntry(date: offset == 0 ? Date() : day,
                                        daysUntilPeriod: PeriodCountdownStore.daysUntilNextPeriod(from: day))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct PeriodCountdownEntry: TimelineEntry {
    let date: Date
    /// Days until the next predicted period; `nil` when nothing has been logged yet.
    let daysUntilPeriod: Int?
}

private enum WidgetColor {
    static let pink = Color(red: 0.86, green: 0.44, blue: 0.59)
    static let blush = Color(red: 0.95, green: 0.80, blue: 0.85)
    static let peach = Color(red: 0.94, green: 0.80, blue: 0.75)
    static let lavender = Color(red: 0.92, green: 0.89, blue: 0.96)
}

struct PeriodTWidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 6) {
            OutlinedNumber(text: headline)
                .frame(maxHeight: .infinity)

            Text(caption)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(WidgetColor.pink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private var headline: String {
        guard let days = entry.daysUntilPeriod else { return "?" }
        return days < 0 ? "\(-days)" : "\(days)"
    }

    private var caption: String {
        guard let days = entry.daysUntilPeriod else { return "Log ur period" }
        switch days {
        case ..<0: return days == -1 ? "Day late" : "Days late"
        case 0: return "Period due today"
        case 1: return "Day till ur period"
        default: return "Days till ur period"
        }
    }
}

/// Big chunky number with a white outline, drawn by stacking offset white copies behind it.
private struct OutlinedNumber: View {
    let text: String
    private let outline: CGFloat = 4

    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { i in
                let angle = Double(i) / 16 * 2 * .pi
                number
                    .foregroundStyle(.white)
                    .offset(x: cos(angle) * outline, y: sin(angle) * outline)
            }
            number
                .foregroundStyle(WidgetColor.pink)
        }
        .minimumScaleFactor(0.5)
    }

    private var number: some View {
        Text(text)
            .font(.system(size: 96, weight: .black, design: .rounded))
            .italic()
            .lineLimit(1)
    }
}

/// Soft pink gradient with a peach glow top-left and lavender glow top-right.
private struct WidgetBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [WidgetColor.peach, WidgetColor.blush],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [WidgetColor.lavender, WidgetColor.lavender.opacity(0)],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 110
            )
            RadialGradient(
                colors: [WidgetColor.blush.opacity(0.6), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 90
            )
        }
    }
}

struct PeriodTWidgetExtension: Widget {
    let kind: String = "PeriodTWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PeriodTWidgetExtensionEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    WidgetBackground()
                }
        }
        .configurationDisplayName("Period Countdown")
        .description("See how many days until your next period.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    PeriodTWidgetExtension()
} timeline: {
    PeriodCountdownEntry(date: .now, daysUntilPeriod: 7)
    PeriodCountdownEntry(date: .now, daysUntilPeriod: 1)
    PeriodCountdownEntry(date: .now, daysUntilPeriod: 0)
    PeriodCountdownEntry(date: .now, daysUntilPeriod: nil)
}
