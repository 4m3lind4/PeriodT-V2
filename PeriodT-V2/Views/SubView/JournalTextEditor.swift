//
//  JournalTextEditor.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  A titled text box with a placeholder, shared by the emotional and workout journals.
//

import SwiftUI

struct JournalTextEditor: View {
    let title: String
    var titleColor: Color = CoreColor.primary

    @Binding var notes: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.system(size: 20, design: .rounded))
                .foregroundColor(titleColor)
            
            // TextEditor doesn't do placeholders, so lay one over the top while it's empty.
            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Type your notes here...")
                        .foregroundColor(CoreColor.primary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .zIndex(1)
                }
                
                TextEditor(text: $notes)
                    .scrollContentBackground(.hidden)
                    .background(CoreColor.ringBackground)
                    .cornerRadius(8)
                    .foregroundStyle(CoreColor.primary)
            }
            .frame(height: 150)
        }
    }
}

#Preview {
    @Previewable @State var notes = ""
    JournalTextEditor(title: "Journal", notes: $notes)
        .padding()
}
