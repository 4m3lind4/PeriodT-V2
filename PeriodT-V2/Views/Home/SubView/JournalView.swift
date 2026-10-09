//
//  JournalView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

struct JournalView: View {
    @Binding var notes: String

    var body: some View {
        JournalTextEditor(title: "Journal", notes: $notes)
    }
}

#Preview {
    @Previewable @State var notes = ""
    JournalView(notes: $notes)
}
