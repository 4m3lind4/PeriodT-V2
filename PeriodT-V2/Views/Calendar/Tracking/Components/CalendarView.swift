//
//  Calendar.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI

/// Scrolling calendar grid covering the past six months and the next two. Highlights predicted period days,
/// logged period days, and days where a program was submitted.
struct CalendarView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel

    @State private var date = Date.now

    @State private var selectedDay: SelectedDay?

    /// Raised when the user taps a day in the future; the enclosing
    /// `errorCardHost` shows the card.
    @Environment(\.presentError) private var presentError

    @EnvironmentObject private var store: TrackingStore

    /// True when the user ticked off a workout in a program due on this day.
    private func completedProgram(on day: Date) -> Bool {
        store.completedProgramDays.contains(day.startOfDay)
    }

    private func answers(for day: Date) -> PollAnswers? {
        store.review(for: day)
    }

    /// True when the user answered "yes" to being on their period that day.
    private func loggedPeriod(on day: Date) -> Bool {
        answers(for: day)?.answers[.onPeriod] == .yes
    }

    /// Capsule that joins up with neighbouring logged days so a run of
    /// period days reads as one continuous pill.
    @ViewBuilder
    private func loggedPeriodOverlay(for day: Date) -> some View {
        if loggedPeriod(on: day) {
            let calendar = Calendar.current
            let previous = calendar.date(byAdding: .day, value: -1, to: day)
            let next = calendar.date(byAdding: .day, value: 1, to: day)
            // If a neighbour can't be computed, just draw a standalone pill.
            let joinsLeft = previous.map(loggedPeriod(on:)) == true && !day.isFirstDayOfRow
            let joinsRight = next.map(loggedPeriod(on:)) == true && !day.isLastDayOfRow
            let radius: CGFloat = 18
            let gap: CGFloat = 8   // the grid's column spacing

            UnevenRoundedRectangle(
                topLeadingRadius: joinsLeft ? 0 : radius,
                bottomLeadingRadius: joinsLeft ? 0 : radius,
                bottomTrailingRadius: joinsRight ? 0 : radius,
                topTrailingRadius: joinsRight ? 0 : radius
            )
            .fill(CoreColor.primary.opacity(0.22))
            .padding(.vertical, 2)
            // Only the trailing side bridges the gap, so neighbours never overlap.
            .padding(.trailing, joinsRight ? -gap : 0)
        }
    }
    
    private let daysOfWeek =
        Date.capitaliseFirstLetterOfWeek

    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 7
    )

    /// Months relative to this one: the last six, this month, and the next two.
    private let monthOffsets = Array(-6...2)

    /// Scroll ID just above the current month. `PeriodTTracking` scrolls here on appear,
    /// so the calendar opens on today rather than six months ago.
    static let currentMonthID = "calendar-current-month"

    private func month(at offset: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: offset, to: date)
    }

    var body: some View {
        // No ScrollView of its own: it sits inside PeriodTTracking's, which does the
        // scrolling (a nested one just grows to full height and never scrolls).
        VStack(spacing: 30) {
            ForEach(monthOffsets, id: \.self) { offset in
                if let month = month(at: offset) {
                    monthCalendar(for: month)
                        // Scroll target sits at the bottom of last month, so landing on it
                        // leaves this month's title in view instead of tucked under the top edge.
                        .overlay(alignment: .bottom) {
                            if offset == -1 {
                                Color.clear
                                    .frame(height: 1)
                                    .id(Self.currentMonthID)
                            }
                        }
                }
            }
        }
        .padding()
        .sheet(item: $selectedDay) { selected in
            DayDetailSheet(day: selected.date)
        }
    }

    /// One month block: title, weekday header row, then the day grid.
    private func monthCalendar(for month: Date) -> some View {
        VStack(spacing: 12) {
            Text(month, format: .dateTime.month(.wide))
                .font(.title3)
                .foregroundStyle(.black)

            Divider()

            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(
                    month.calendarDisplayDays,
                    id: \.self
                ) { day in
                    calendarDay(day, in: month)
                }
            }
        }
    }

    /// A single tappable day cell. Past/today opens the detail sheet;
    /// future days trigger the error card instead.
    @ViewBuilder
    private func calendarDay(
        _ day: Date,
        in month: Date
    ) -> some View {
        // Leading days from the previous month are rendered as blank spacers.
        if day.monthInt != month.monthInt {
            Color.clear
                .frame(
                    maxWidth: .infinity,
                    minHeight: 50
                )
        } else {
            Button {
                if day.startOfDay <= Date().startOfDay {
                    selectedDay = SelectedDay(id: day.startOfDay)
                } else {
                    presentError(.futureDay(day.startOfDay))
                }
            } label: {
                ZStack {
                    dayBackground(for: day)
                    Text(day.formatted(.dateTime.day()))
                        .foregroundStyle(CoreColor.primary)

                }
                .overlay { loggedPeriodOverlay(for: day) }
                .overlay {
                    Text(day.formatted(.dateTime.day()))
                        .foregroundStyle(CoreColor.primary)
                        .opacity(loggedPeriod(on: day) ? 1 : 0)
                }
                .frame(maxWidth: .infinity, minHeight: 45)
                .overlay(alignment: .bottom) {
                    if completedProgram(on: day) {
                        Circle()
                            .fill(CoreColor.secondary)
                            .frame(width: 4, height: 4)
                            .padding(.bottom, 5)
                    }
                }
                .contentShape(Rectangle())
                
            }
            .buttonStyle(.plain)
            // The visible label is just the day number, which repeats in every month.
            .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
            .accessibilityIdentifier(Self.dayIdentifier(for: day))
        }
    }

    /// Stable identifier for a day cell, e.g. "calendar-day-2026-10-07".
    static func dayIdentifier(for day: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: day)
        return String(format: "calendar-day-%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// Lavender circle marking today. Logged period days are drawn by
    /// `loggedPeriodOverlay`; predicted days are intentionally not shown.
    @ViewBuilder
    private func dayBackground(for day: Date) -> some View {
        if Date.now.startOfDay == day.startOfDay {
            Circle()
                .foregroundStyle(CoreColor.lavender.opacity(0.8))
        } else {
            Color.clear
        }
    }
}

#Preview {
    CalendarView(calendarViewModel: CalendarViewModel())
    .errorCardHost()
    .previewTrackingStore()
}
