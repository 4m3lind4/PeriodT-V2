//
//  CycleProgressRing.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation
import SwiftUI

/// Circular cycle ring. Draws a background track, an animated progress arc,
/// a "period" marker at the start, and a "user" marker at the current progress.
struct CycleProgressRing: View {
    @Binding var progress: Float
    private let strokeWidth: CGFloat = 32.0
    // 270° = 12 o'clock, so the ring starts at the top.
    private let startDegrees: Double = 270.0

    /// Converts an angle (degrees) into a point on the ring's circumference.
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
            // Work out where the start, progress and pre-start markers sit.
            let startAngle = startDegrees - 360
            let endAngle = startAngle + Double(progress) * 360.0

            let startPos    = endPosition(for: startAngle, in: size)
            let endPos      = endPosition(for: endAngle, in: size)


            ZStack {
                // Background track
                Circle()
                    .stroke(
                        CoreColor.ringBackground,
                        lineWidth: 40.0
                    )
                
                    .opacity(0.70)
                // Progress arc - trimmed to `progress` and animated on change
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
                
                
                //PERIOD DEADLINE
                Circle()
                    .fill(CoreColor.primary)
                    .frame(width: strokeWidth, height: strokeWidth)
                    .overlay(
                        Image(systemName: "drop.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                )
                    .position(startPos)
                //USER CIRCLE
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

    /// Days-until-period countdown and current phase, shown inside the ring.
    private var centerLabel: some View {
        VStack {
            Text("Period in")
                .font(.title3)
            // Number of days remaining
            Text("7")
                .font(.largeTitle)
                .bold()

            Text("Days")
                .font(.title3)

            Text("Luteral Phase")
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
}
