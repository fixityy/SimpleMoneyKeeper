//
//  DateExtension.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 14.11.2022.
//

import Foundation

extension Date {
    //Get date, according to user's location UTC
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
}
