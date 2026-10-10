//
//  ColorExtension.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  Lets me write colours as "#RRGGBB" strings, which is how they come out of the
//  Figma designs. CoreColor is built on top of this.
//

import SwiftUI

extension Color {
    /// Creates a colour from a "#RRGGBB" string.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        // The hex is one 24-bit number, so shift and mask to pull out each 8-bit channel.
        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        
        self.init(
            red: red,
            green: green,
            blue: blue
        )
    }
}
