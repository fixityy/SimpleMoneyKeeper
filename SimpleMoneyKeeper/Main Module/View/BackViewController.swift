//
//  BackViewContro.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.10.2022.
//

import UIKit

class BackViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainAccentColor
        
//        test()
    }
    
    private func test() {
        
        let date1 = Date(timeIntervalSinceNow: 0)
        let date2 = Date(timeIntervalSinceNow: 41234123)
        let date3 = Date(timeIntervalSinceNow: 1231232)
        
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "yyyy.MM"
        
        let d1 = dataFormatter.string(from: date1)
        let d2 = dataFormatter.string(from: date2)
        let d3 = dataFormatter.string(from: date3)
        
        let d4 = date1.formatted(.dateTime.month(.wide))
        let d5 = date1.formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        let d6 = date2.formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        
        let d7 = date1.formatted(date: .numeric, time: .omitted)
        let d8 = date2.formatted(date: .numeric, time: .omitted)
        let d9 = date3.formatted(date: .numeric, time: .omitted)

        print(d4)
        print(d5)
        print(d6)

        d5 == d6 ? print("true") : print("false")
        
        print(d1)
        print(d2)
        print(d3)
        
        let array = [d1, d2, d3]
        let array2 = [date1, date2, date3]
        let array3 = [d9, d8, d9, d7]
        let array4 = [d5, d6, d6, d5]

        print(array.sorted(by: < ))
        print(array2.sorted(by: < ))
        print(array3.sorted(by: <))
        print(array4.sorted(by: <))
        
        d1 < d2 ? print("true") : print("false")
        
    }

}

