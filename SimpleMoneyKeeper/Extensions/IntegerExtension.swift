//
//  IntegerExtension.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 19.11.2022.
//

import Foundation

extension Int {
    func stringWithSpaceEveryThreeDigits() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        return formatter.string(for: self) ?? ""
    }
}
