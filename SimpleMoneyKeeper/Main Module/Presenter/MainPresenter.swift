//
//  MainPresenter.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 09.11.2022.
//

import Foundation
import CoreData
import Charts
import UIKit

protocol FrontViewProtocol: AnyObject {
    func updateTableView()
}

protocol BackViewProtocol: AnyObject {
    func updatePreviosCell(at newIndexPath: IndexPath)
    func reloadCollectionView()
}

protocol MainPresenterProtocol: AnyObject {
    var datesArray: [Date] { get set }
    var monthrTotalSpent: Int { get set }
    
    func setBackDelegate(delegate: BackViewProtocol)
    func addOrSubtractMonth(month: Int) -> Date
    func addPreviousDate(at newIndexPath: IndexPath)
    func addNextDate()
    func presentDate(at index: Int) -> NSMutableAttributedString
    func performFetchPieChart()
    func presentPieChartData() -> PieChartData
    func reloadBackVCCollectionView()
    
    var dataStoreManager: DataStoreManager { get }
    var fetchResultController: NSFetchedResultsController<Spent> { get }
    
    func setFrontDelegate(delegate: FrontViewProtocol)
    func performFetch()
    func presentSpent(index: IndexPath) -> Spent
    func updateFetchResultPredicate(index: Int)
    func reloadTableView()
    
    func presentAddSpentVC(viewController: UIViewController)
}

class MainPresenter: MainPresenterProtocol {
    
    //MARK: BackVC Presenter
    weak var backDelegate: BackViewProtocol?
        
    lazy var datesArray: [Date] = {
        var array = [Date]()
        for i in -5...5 {
            array.append(addOrSubtractMonth(month: i))
        }
        return array
    }()
    
    var decreaseMonth = -6
    var increaseMonth = 6

    var monthrTotalSpent = 0
    
    lazy var pieChartFetchResultController: NSFetchedResultsController<Spent> = {
        let fetchRequest = Spent.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Spent.category), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let sortPredicate = Date().localDate().formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        let predicate = NSPredicate(format: "dateSort == %@", sortPredicate)
        
        fetchRequest.predicate = predicate
        
        let fetchResultController = NSFetchedResultsController<Spent>(fetchRequest: fetchRequest, managedObjectContext: dataStoreManager.context, sectionNameKeyPath: #keyPath(Spent.category), cacheName: nil)

        return fetchResultController
    }()
    
    func setBackDelegate(delegate: BackViewProtocol) {
        self.backDelegate = delegate
    }
    
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date().localDate())!
    }

    func addPreviousDate(at newIndexPath: IndexPath) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
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
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            guard let self = self else { return }
            self.datesArray.insert(self.addOrSubtractMonth(month: self.increaseMonth), at: self.datesArray.endIndex)
            self.increaseMonth += 1
            DispatchQueue.main.async {
                self.backDelegate?.reloadCollectionView()
            }
        }
    }
    
    func performFetchPieChart() {
        do {
            try pieChartFetchResultController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func presentDate(at index: Int) -> NSMutableAttributedString{
        let str = datesArray[index].formatted(.dateTime.month(.wide)).capitalizeFirstCharacter() + "\n" + datesArray[index].formatted(.dateTime.year(.defaultDigits)) + "\n" + "\n" + monthrTotalSpent.stringWithSpaceEveryThreeDigits() + "  \u{20BD}"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let centerText = NSMutableAttributedString(string: str)
        centerText.setAttributes([.font : UIFont.systemFont(ofSize: 18), .paragraphStyle: paragraph], range: NSRange(location: 0, length: centerText.length))
        
        return centerText
    }
    
    func presentPieChartData() -> PieChartData {
        
        monthrTotalSpent = 0
        
        guard let sectionsCount = pieChartFetchResultController.sections?.count else { return PieChartData() }
        guard let sectionInfo = pieChartFetchResultController.sections else { return PieChartData() }

        var entries = [PieChartDataEntry]()

        for section in 0..<sectionsCount {
            var spentAmount: Int64 = 0
            var sectionName = ""
            for object in 0..<sectionInfo[section].numberOfObjects {
                spentAmount += pieChartFetchResultController.object(at: IndexPath(row: object, section: section)).spentAmount
                
                sectionName = pieChartFetchResultController.object(at: IndexPath(row: object, section: section)).category ?? ""
            }

            let entry = PieChartDataEntry(value: Double(spentAmount), label: sectionName)
            entries.append(entry)
            monthrTotalSpent += Int(spentAmount)
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        
        set.colors = ChartColorTemplates.vordiplom()
        
        set.sliceSpace = 2
        
        set.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: set)
        
        return data
    }
    
    func reloadBackVCCollectionView() {
        backDelegate?.reloadCollectionView()
    }
    
    //MARK: FrontVC Presenter
    
    weak var frontDelegate: FrontViewProtocol?
    
    lazy var dataStoreManager = DataStoreManager()
    
    lazy var fetchResultController: NSFetchedResultsController<Spent> = {
        let fetchRequest = Spent.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Spent.date), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let sortPredicate = Date().localDate().formatted(.dateTime.year(.defaultDigits).month(.defaultDigits))
        let predicate = NSPredicate(format: "dateSort == %@", sortPredicate)
        
        fetchRequest.predicate = predicate
        
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
        pieChartFetchResultController.fetchRequest.predicate = predicate
        performFetch()
        performFetchPieChart()
        frontDelegate?.updateTableView()
        backDelegate?.reloadCollectionView()
    }
    
    func reloadTableView() {
        frontDelegate?.updateTableView()
    }
    
    func presentAddSpentVC(viewController: UIViewController) {
        let addSpentPresenter = AddSpentPresenter()
        addSpentPresenter.mainPresenter = self
        let addSpentVC = AddSpentViewController(with: addSpentPresenter)
        viewController.present(addSpentVC, animated: true)
    }
}
