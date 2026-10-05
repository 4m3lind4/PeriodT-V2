//
//  ExerciseThumbnail.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import SwiftUI

struct ExerciseThumbnail: View {
    let url: URL?
    var size: CGFloat = 48

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(CoreColor.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CoreColor.ringBackground)
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: 10))
    }
}

#Preview {
    HStack {
        ExerciseThumbnail(url: ExerciseImageCatalog.imageURL(for: "Squat"))
        ExerciseThumbnail(url: nil)
    }
}
