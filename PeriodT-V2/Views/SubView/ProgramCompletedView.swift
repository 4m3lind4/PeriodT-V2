//
//  ProgramCompletedView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// "Great Job" screen shown after a program is submitted.
struct ProgramCompletedView: View {
    @EnvironmentObject private var navigation: AppNavigationViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 96))
                .foregroundStyle(CoreColor.primary)

            Text("Great Job!")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(CoreColor.primary)

            Text("Your program has been saved.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(CoreColor.primary.opacity(0.7))

            Spacer()

            // Clears the whole exercise stack, landing back on the program list.
            Button {
                navigation.returnHome()
            } label: {
                PrimaryButtonLabel(title: "Done", style: .filled)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        // Back would return to the already-submitted checklist, so hide it.
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        ProgramCompletedView()
    }
    .environmentObject(AppNavigationViewModel())
}
