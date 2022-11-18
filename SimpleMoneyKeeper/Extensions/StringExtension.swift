//
//  StringExtension.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 18.11.2022.
//

import Foundation

extension String {
      func capitalizeFirstLetter() -> String {
           return self.prefix(1).capitalized + dropFirst()
      }
 }
