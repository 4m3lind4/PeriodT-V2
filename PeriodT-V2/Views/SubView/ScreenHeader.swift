//
//  ScreenHeader.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//
//  The title row at the top of each tab, with the profile icon on the right.
//

import SwiftUI

/// Pass in `content` to swap the plain title for something else, like Home's greeting.
struct ScreenHeader<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
            Spacer()
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(CoreColor.lavender)
                .font(.system(size: 50, weight: .bold))
        }
    }
}

extension ScreenHeader where Content == Text {
    /// Shortcut for the usual case of just a title.
    init(title: String) {
        self.init {
            Text(title)
                .font(Font.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(CoreColor.primary)
        }
    }
}

#Preview {
    ScreenHeader(title: "Today's Program")
        .padding()
}
