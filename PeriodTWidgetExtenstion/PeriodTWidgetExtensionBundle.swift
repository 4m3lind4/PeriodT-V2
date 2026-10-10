//
//  PeriodTWidgetExtensionBundle.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Registers everything the extension provides: the countdown widget and the
//  workout Live Activity.
//

import WidgetKit
import SwiftUI

@main
struct PeriodTWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        PeriodTWidgetExtension()
        WorkoutLiveActivity()
    }
}
