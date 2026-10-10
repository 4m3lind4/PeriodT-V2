//
//  PeriodTTracking.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//

import SwiftUI

/// Calendar tab: shows the period-due countdown above a scrolling calendar (past six months to two ahead).
struct PeriodTTracking: View {
    @EnvironmentObject private var store: TrackingStore

    private let periodDue = PeriodDueViewModel()

    var body: some View {
        // The reader lets us jump past the earlier months to the current one.
        ScrollViewReader { proxy in
            ScrollView{
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
                    CalendarView(calendarViewModel: CalendarViewModel())
                }
            }
            .onAppear {
                proxy.scrollTo(CalendarView.currentMonthID, anchor: .top)
            }
            // Over the scroll view rather than inside it, so it stays put while scrolling.
            .overlay {
                GradientOverlayView()
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .refreshable { await store.load() }
        // Shows the slide-up card for future-day taps and failed saves
        // raised anywhere inside the calendar.
        .errorCardHost()
    }
}

#Preview {
    PeriodTTracking()
        .previewTrackingStore()
}
