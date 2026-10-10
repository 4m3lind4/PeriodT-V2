//
//  CoreColor.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  The PeriodT colour palette. Every view pulls its colours from here rather than
//  hard-coding hex values, so if the brand colours ever change it's a one-file job.
//

import Foundation
import SwiftUI

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
    
    // MARK: Program Status Colours
    static let completed      = Color(hex: "#F08054")

    static let missed         = Color(hex: "#B9AAB2") // in the past and not finished
    
    static let current        = Color(hex: "#DB6E96") // today
    
    static let incoming       = Color(hex: "#AB7AC7") // coming up
    
    static let physioAccent   = Color(hex: "#FAD94A")
    
    static let cardBackground = Color(hex: "#FCEBF0") // light pink

    static let cardTray       = Color(hex: "#FDF7F9") // expanded card body
}
