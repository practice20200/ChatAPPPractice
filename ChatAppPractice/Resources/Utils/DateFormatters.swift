//
//  DateFomatters.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-16.
//

import Foundation
import UIKit

class DateFormatters {
    static func dateFormattersChatView(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter.string(from: date)
    }

}
