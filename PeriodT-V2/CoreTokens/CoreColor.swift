//
//  CoreColor.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//


import Foundation
import SwiftUI

/// App colour palette. Use these instead of hard-coded hex values in views.
public final class CoreColor {
    
    // MARK: Primary Brand Colours
    
    static var primary: Color = Color(hex: "#D96F94")
    
    static var secondary: Color = Color(hex: "#A875A6")
    
    // MARK: Background Colours
    
    static var ringBackground: Color = Color(hex: "#FFEBF2")
    
    static var lavender: Color = Color(hex: "#DEC6E8")
    
    // MARK: Accent Colours
    
    static var accent: Color = Color(hex: "#EE7D56")
    
    static var white: Color = Color(hex: "#FFFFFF")
    
    static var yellow: Color = Color(hex: "#FAD72C")
    
    // MARK: Active Colours
    static let completed      = Color(hex: "#F08054") // Completed
    
    static let current        = Color(hex: "#DB6E96") // Current
    
    static let incoming       = Color(hex: "#AB7AC7") // Incoming
    
    static let physioAccent   = Color(hex: "#FAD94A") // Physio
    
    static let cardBackground = Color(hex: "#FCEBF0") // light pink
}
