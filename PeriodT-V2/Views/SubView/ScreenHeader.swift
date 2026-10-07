//
//  ScreenHeader.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//


//
//  ScreenHeader.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Page title on the left with the profile icon on the right.
/// Pass custom `content` to replace the plain title (e.g. the Home greeting).
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
    /// Convenience for the common single-title case.
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
