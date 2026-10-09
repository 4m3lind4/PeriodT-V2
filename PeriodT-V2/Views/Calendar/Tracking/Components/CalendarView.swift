//
//  Calendar.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI
import SwiftData

/// Scrolling 3-month calendar grid. Highlights predicted period days,
/// logged period days, and days where a program was submitted.
struct CalendarView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel

    @State private var date = Date.now

    @State private var selectedDay: SelectedDay?

    /// Raised when the user taps a day in the future; the enclosing
    /// `errorCardHost` shows the card.
    @Environment(\.presentError) private var presentError

    @Query private var allAnswers: [PollAnswers]
    @Query private var completedPrograms: [CompletedProgram]

    /// True when the user submitted a program that was due on this day.
    private func completedProgram(on day: Date) -> Bool {
        completedPrograms.contains { $0.date == day.startOfDay }
    }

    private func answers(for day: Date) -> PollAnswers? {
        allAnswers.first { $0.date == day.startOfDay }
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

    /// This month plus the next two.
    private var monthsArray: [Date] {
        (0..<3).compactMap { monthOffset in
            Calendar.current.date(
                byAdding: .month,
                value: monthOffset,
                to: date
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(monthsArray, id: \.self) { month in
                    monthCalendar(for: month)
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
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
        }
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
    .modelContainer(for: [PollAnswers.self, CompletedProgram.self], inMemory: true)
}
