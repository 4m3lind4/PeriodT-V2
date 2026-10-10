//
//  PeriodTWidgetExtensionLiveActivity.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PeriodTWidgetExtensionAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PeriodTWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PeriodTWidgetExtensionAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PeriodTWidgetExtensionAttributes {
    fileprivate static var preview: PeriodTWidgetExtensionAttributes {
        PeriodTWidgetExtensionAttributes(name: "World")
    }
}

extension PeriodTWidgetExtensionAttributes.ContentState {
    fileprivate static var smiley: PeriodTWidgetExtensionAttributes.ContentState {
        PeriodTWidgetExtensionAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PeriodTWidgetExtensionAttributes.ContentState {
         PeriodTWidgetExtensionAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PeriodTWidgetExtensionAttributes.preview) {
   PeriodTWidgetExtensionLiveActivity()
} contentStates: {
    PeriodTWidgetExtensionAttributes.ContentState.smiley
    PeriodTWidgetExtensionAttributes.ContentState.starEyes
}
