//
//  MainPresenter.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 09.11.2022.
//

import Foundation
import CoreData

protocol FrontViewProtocol: AnyObject {
    
}

protocol BackViewProtocol: AnyObject {
    func updatePreviosCell(at newIndexPath: IndexPath)
    func updateNextCell()
}

protocol MainPresenterProtocol: AnyObject {
    var datesArray: [Date] { get set }
    
    func setBackDelegate(delegate: BackViewProtocol)
    func addOrSubtractMonth(month: Int) -> Date
    func addPreviousDate(at newIndexPath: IndexPath)
    func addNextDate()
    func presentDate(at index: Int) -> String
}

class MainPresenter: MainPresenterProtocol {
    
    //MARK: BackVC Presenter
    weak var backDelegate: BackViewProtocol?
    
    lazy var datesArray = [addOrSubtractMonth(month: -1), addOrSubtractMonth(month: 0), addOrSubtractMonth(month: 1)]

    var decreaseMonth = -2
    var increaseMonth = 2
    
    func setBackDelegate(delegate: BackViewProtocol) {
        self.backDelegate = delegate
    }
    
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }

    func addPreviousDate(at newIndexPath: IndexPath) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.datesArray.insert(self.addOrSubtractMonth(month: self.decreaseMonth), at: 0)
            self.decreaseMonth -= 1
            
            DispatchQueue.main.async { 
                self.backDelegate?.updatePreviosCell(at: newIndexPath)
            }
        }
    }
    
    func addNextDate() {
        datesArray.insert(addOrSubtractMonth(month: increaseMonth), at: datesArray.endIndex)
        increaseMonth += 1
        backDelegate?.updateNextCell()
    }
    
    func presentDate(at index: Int) -> String{
        datesArray[index].formatted()
    }
    
    //MARK: FrontVC Presenter
    
    
}
