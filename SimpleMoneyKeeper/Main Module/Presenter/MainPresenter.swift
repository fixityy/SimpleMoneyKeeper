//
//  MainPresenter.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 09.11.2022.
//

import Foundation
import CoreData

protocol FrontViewProtocol: AnyObject {
    func updateTableView()
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
    
    var dataStoreManager: DataStoreManager { get }
    var fetchResultController: NSFetchedResultsController<Spent> { get }
    
    func setFrontDelegate(delegate: FrontViewProtocol)
    func performFetch()
    func presentSpent(index: IndexPath) -> Spent
    func updateFetchResultPredicate(index: Int)
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
        Calendar.current.date(byAdding: .month, value: month, to: Date().localDate())!
    }

    func addPreviousDate(at newIndexPath: IndexPath) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.datesArray.insert(self.addOrSubtractMonth(month: self.decreaseMonth), at: 0)
            self.decreaseMonth -= 1
            
            DispatchQueue.main.async { 
                self.backDelegate?.updatePreviosCell(at: newIndexPath)
                self.updateFetchResultPredicate(index: newIndexPath.row + 1)
            }
        }
    }
    
    func addNextDate() {
        DispatchQueue.global().async {[weak self] in
            guard let self = self else { return }
            self.datesArray.insert(self.addOrSubtractMonth(month: self.increaseMonth), at: self.datesArray.endIndex)
            self.increaseMonth += 1
            DispatchQueue.main.async {
                self.backDelegate?.updateNextCell()
            }
        }
        
    }
    
    func presentDate(at index: Int) -> String{
        datesArray[index].formatted()
    }
    
    //MARK: FrontVC Presenter
    
    weak var frontDelegate: FrontViewProtocol?
    
    lazy var dataStoreManager = DataStoreManager()
    
    lazy var fetchResultController: NSFetchedResultsController<Spent> = {
        let fetchRequest = Spent.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Spent.date), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultController = NSFetchedResultsController<Spent>(fetchRequest: fetchRequest, managedObjectContext: dataStoreManager.context, sectionNameKeyPath: #keyPath(Spent.dateStr), cacheName: nil)

        return fetchResultController
    }()
    
    func setFrontDelegate(delegate: FrontViewProtocol) {
        self.frontDelegate = delegate
    }
    
    func performFetch() {
        do {
            try fetchResultController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func presentSpent(index: IndexPath) -> Spent {
        return fetchResultController.object(at: index)
    }
    
    func updateFetchResultPredicate(index: Int) {
        let sortPredicate = datesArray[index].formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        let predicate = NSPredicate(format: "dateSort == %@", sortPredicate)
        fetchResultController.fetchRequest.predicate = predicate
        performFetch()
        frontDelegate?.updateTableView()
    }
}
