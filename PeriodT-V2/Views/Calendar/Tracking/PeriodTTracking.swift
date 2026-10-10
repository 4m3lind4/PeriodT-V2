//
//  PeriodTTracking.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//
//  The Calendar tab. A "Period Due" countdown pinned at the top with the
//  scrolling calendar underneath.
//

import SwiftUI

struct PeriodTTracking: View {
    @EnvironmentObject private var store: TrackingStore

    /// Owned up here so it survives redraws. `CalendarView` keeps it fed from the store.
    @StateObject private var calendarViewModel = CalendarViewModel()

    private let periodDue = PeriodDueViewModel()

    var body: some View {
        // The reader lets us skip past the older months and land on this one.
        ScrollViewReader { proxy in
            ScrollView{
                CalendarView(calendarViewModel: calendarViewModel)
            }
            // Pinned above the calendar so the countdown stays in view while scrolling.
            .safeAreaInset(edge: .top) {
                periodDueHeader
            }
            .onAppear {
                proxy.scrollTo(CalendarView.currentMonthID, anchor: .top)
            }
            // Sits over the scroll view rather than inside it, so it doesn't scroll away.
            .overlay {
                GradientOverlayView()
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .refreshable { await store.load() }
        // Catches future-day taps and failed saves from anywhere inside the calendar.
        .errorCardHost()
    }

    private var periodDueHeader: some View {
        VStack(alignment: .center, spacing: 12){
            Text("Period Due")
                .font(Font.system(size: 20, design: .rounded))
                .foregroundColor(CoreColor.primary)
            Text(periodDue.dueText(for: store.allReviews))
                .font(Font.system(size: 30,weight: .bold, design: .rounded))
                .foregroundColor(CoreColor.primary)
                .frame(width: 300)
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CoreColor.ringBackground)
                        .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        // Solid background so the days don't show through as they scroll underneath.
        .background(Color(.systemBackground))
    }
}

#Preview {
    PeriodTTracking()
        .previewTrackingStore()
}
