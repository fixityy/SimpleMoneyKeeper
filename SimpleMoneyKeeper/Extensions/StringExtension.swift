//
//  StringExtension.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 19.11.2022.
//

import Foundation

extension String {
       func capitalizeFirstCharacter() -> String {
            return self.prefix(1).capitalized + dropFirst()
       }
  }
