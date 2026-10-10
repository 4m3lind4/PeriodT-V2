//
//  CalendarView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//
//  The scrolling month grid on the Calendar tab, from six months back to two
//  ahead. It marks today, logged period days (joined up into one pill) and days
//  where a workout was ticked off. Tapping a past day opens its detail sheet.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel

    @State private var date = Date.now

    @State private var selectedDay: SelectedDay?

    /// Called when a future day is tapped. The `errorCardHost` further up shows the card.
    @Environment(\.presentError) private var presentError

    @EnvironmentObject private var store: TrackingStore

    /// Whether the athlete ticked off a workout in a program on this day.
    private func completedProgram(on day: Date) -> Bool {
        store.completedProgramDays.contains(day.startOfDay)
    }

    /// Whether the athlete said "yes" to being on their period that day.
    private func loggedPeriod(on day: Date) -> Bool {
        calendarViewModel.isLoggedPeriodDay(day)
    }

    /// Draws the pink pill behind logged period days. Each day checks its neighbours
    /// and squares off whichever side touches another period day, so a run of days
    /// reads as one pill. It stops at the end of a row so it doesn't wrap around.
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
            // Only the right side stretches over the gap, so neighbours never overlap.
            .padding(.trailing, joinsRight ? -gap : 0)
        }
    }
    
    private let daysOfWeek =
        Date.capitaliseFirstLetterOfWeek

    private let columns = Array(
        repeating: GridItem(.flexible()),
        count: 7
    )

    /// Months relative to this one: the last six, this month and the next two.
    private let monthOffsets = Array(-6...2)

    /// Scroll target just above this month. `PeriodTTracking` jumps here on appear so
    /// the calendar opens on today rather than six months ago.
    static let currentMonthID = "calendar-current-month"

    private func month(at offset: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: offset, to: date)
    }

    var body: some View {
        // No ScrollView in here on purpose. It sits inside PeriodTTracking's one, and a
        // nested ScrollView just grows to full height and never actually scrolls.
        VStack(spacing: 30) {
            ForEach(monthOffsets, id: \.self) { offset in
                if let month = month(at: offset) {
                    monthCalendar(for: month)
                        // The scroll target goes at the bottom of last month, so landing on it
                        // leaves this month's title in view rather than tucked under the header.
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
        // Keep the logged and predicted days in step with the store.
        .onChange(of: store.reviews, initial: true) { _, _ in
            calendarViewModel.update(with: store.allReviews)
        }
        .sheet(item: $selectedDay) { selected in
            DayDetailSheet(day: selected.date)
        }
    }

    /// One month: the title, a row of weekday letters, then the day grid.
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

    /// A single day. Today or earlier opens the detail sheet, future days show the
    /// error card instead since there's nothing to log yet.
    @ViewBuilder
    private func calendarDay(
        _ day: Date,
        in month: Date
    ) -> some View {
        // Days from last month that pad out the first row are just blank space.
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
            // The day number alone repeats every month, so give VoiceOver the full date.
            .accessibilityLabel(day.formatted(date: .complete, time: .omitted))
            .accessibilityIdentifier(Self.dayIdentifier(for: day))
        }
    }

    /// Identifier for a day cell so the UI tests can find it, e.g. "calendar-day-2026-10-07".
    static func dayIdentifier(for day: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: day)
        return String(format: "calendar-day-%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// Lavender circle for today. Logged period days are drawn by `loggedPeriodOverlay`.
    /// Predicted days are left off the grid on purpose.
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
