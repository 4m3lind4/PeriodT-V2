//
//  CatalogAndColorTests.swift
//  PeriodT-V2Tests
//

import Foundation
import SwiftUI
import UIKit
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("ExerciseImageCatalog")
struct ExerciseImageCatalogTests {

    @Test(arguments: ["Goblet Squat", "Hip Thrust", "Plank", "Farmer's Walk", "Push-up"])
    func knownExercisesHaveAnImage(_ name: String) throws {
        let url = try #require(ExerciseImageCatalog.imageURL(for: name))
        #expect(url.scheme == "https")
    }

    @Test(arguments: [
        ("Goblet Squat", "goblet squats"),
        ("Farmer's Walk", "FARMERS WALK"),
        ("Push-up", "pushup"),
        ("Plank", "Planks")
    ])
    func lookupIgnoresCasePunctuationAndPlurals(canonical: String, variant: String) {
        #expect(ExerciseImageCatalog.imageURL(for: variant) == ExerciseImageCatalog.imageURL(for: canonical))
        #expect(ExerciseImageCatalog.imageURL(for: variant) != nil)
    }

    @Test(arguments: ["", "Underwater Basket Weaving", "!!!"])
    func unknownExercisesHaveNoImage(_ name: String) {
        #expect(ExerciseImageCatalog.imageURL(for: name) == nil)
    }

    @Test func workoutImageURLUsesCatalog() {
        #expect(Workout(name: "Hip Thrust").imageURL == ExerciseImageCatalog.imageURL(for: "Hip Thrust"))
    }
}

@MainActor
@Suite("Color(hex:)")
struct ColorHexTests {

    private func components(_ color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue)
    }

    @Test(arguments: ["#D96F94", "D96F94", "  #d96f94 "])
    func parsesBrandPinkWithOrWithoutHash(_ hex: String) {
        let parsed = components(Color(hex: hex))
        #expect(abs(parsed.red - 217 / 255) < 0.005)
        #expect(abs(parsed.green - 111 / 255) < 0.005)
        #expect(abs(parsed.blue - 148 / 255) < 0.005)
    }

    @Test func parsesBlackAndWhite() {
        let white = components(Color(hex: "#FFFFFF"))
        let black = components(Color(hex: "#000000"))
        #expect(white.red > 0.995 && white.green > 0.995 && white.blue > 0.995)
        #expect(black.red < 0.005 && black.green < 0.005 && black.blue < 0.005)
    }

    @Test func invalidHexFallsBackToBlack() {
        let parsed = components(Color(hex: "not a colour"))
        #expect(parsed.red < 0.005 && parsed.green < 0.005 && parsed.blue < 0.005)
    }
}
