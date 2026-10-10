//
//  DateExtension.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  Date formatting for program cards (e.g. "MON 14 SEP").
//

import Foundation

extension Date {
    /// e.g. "MON 14 SEP"
    func formattedProgramDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self).uppercased()
    }
}
