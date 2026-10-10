//
//  CycleProgressRing.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The ring on Home that counts down to the next period. The arc shrinks back
//  towards the droplet as the period gets closer, and the smiley marks where the
//  athlete is today. Purely visual, all the numbers come in from CycleRingView.
//

import Foundation
import SwiftUI

struct CycleProgressRing: View {
    @Binding var progress: Float
    /// Days until the next period, or nil if no period has been logged yet.
    var daysUntilPeriod: Int?
    var phase: String
    private let strokeWidth: CGFloat = 32.0

    private let startDegrees: Double = 270.0

    /// Turns an angle in degrees into a point on the ring, so the markers can sit on the track.
    func endPosition(for angle: Double, in size: CGSize) -> CGPoint {
        let radius = (min(size.width, size.height) / 2) - (strokeWidth / 2) + 16
        let radians = angle * .pi / 180
        return CGPoint(
            x: size.width / 2 + radius * CGFloat(cos(radians)),
            y: size.height / 2 + radius * CGFloat(sin(radians))
        )
    }
    
    var body: some View{
        
        GeometryReader{ geometry in
            let size = geometry.size
            // The ring starts at the top (270°) and goes clockwise, so the droplet sits at
            // the start and the smiley sits wherever the progress arc ends.
            let startAngle = startDegrees - 360
            let endAngle = startAngle + Double(progress) * 360.0

            let startPos    = endPosition(for: startAngle, in: size)
            let endPos      = endPosition(for: endAngle, in: size)


            ZStack {
                // Background track.
                Circle()
                    .stroke(
                        CoreColor.ringBackground,
                        lineWidth: 40.0
                    )
                
                    .opacity(0.70)
                // Progress arc, trimmed to `progress` and animated when it changes.
                Circle()
                    .trim(
                        from: 0.0,
                        to: CGFloat(min(self.progress, 1.0))
                    )
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                CoreColor.primary,
                                CoreColor.ringBackground
                                
                                
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(
                            lineWidth: 32.0,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .rotationEffect(.degrees(startDegrees))
                    .animation(
                        .easeInOut(duration: 2.0),
                        value: progress
                    )
                
                
                // Droplet marking when the period is due.
                Circle()
                    .fill(CoreColor.primary)
                    .frame(width: strokeWidth, height: strokeWidth)
                    .overlay(
                        Image(systemName: "drop.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                )
                    .position(startPos)
                // Smiley marking where the athlete is today.
                Circle()
                    .fill(CoreColor.ringBackground)
                    .stroke(CoreColor.ringBackground, lineWidth: 4)
                    .frame(width: strokeWidth, height: strokeWidth)
                    .overlay(
                        Image(systemName: "face.smiling.inverse")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(CoreColor.secondary)
                )
                    .position(endPos)
                
                centerLabel
            }
        }
    }

    /// The countdown and current phase in the middle of the ring.
    private var centerLabel: some View {
        VStack {
            if let days = daysUntilPeriod, days > 0 {
                Text("Period in")
                    .font(.title3)
                Text("\(days)")
                    .font(.largeTitle)
                    .bold()

                Text(days == 1 ? "Day" : "Days")
                    .font(.title3)
            } else if let days = daysUntilPeriod {
                Text(days == 0 ? "Period due" : "Period late")
                    .font(.title3)
                Text(days == 0 ? "Today" : "\(-days) \(days == -1 ? "Day" : "Days")")
                    .font(.largeTitle)
                    .bold()
            } else {
                Text("Log your period")
                    .font(.title3)
            }

            Text(phase)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 150, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(CoreColor.secondary)
                )
                .padding(.top, 1)
        }
        .foregroundStyle(CoreColor.primary)
    }
}

#Preview {
    CycleRingView()
        .previewTrackingStore()
}
