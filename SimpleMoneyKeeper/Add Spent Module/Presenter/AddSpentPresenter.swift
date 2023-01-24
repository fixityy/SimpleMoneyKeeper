//
//  AddSpentPresenter.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.11.2022.
//

import Foundation

protocol AddSpentViewProtocol {
    
}

protocol AddSpentPresenterProtocol {
    var categories: [SpentCategory] { get }
    func presentCategory(index: IndexPath) -> SpentCategory
    func addNewSpent(date: Date, spentCategory: SpentCategory, spentAmount: Int, note: String)
}

class AddSpentPresenter: AddSpentPresenterProtocol {
    
    weak var mainPresenter: MainPresenterProtocol?
    
    var categories: [SpentCategory] {
        get {
            return [SpentCategory(category: "Автомобиль", categoryIconStr: "car"), SpentCategory(category: "Покупки", categoryIconStr: "cart"), SpentCategory(category: "Подарки", categoryIconStr: "gift"), SpentCategory(category: "Развлечения", categoryIconStr: "film"), SpentCategory(category: "Автомобиль", categoryIconStr: "car"), SpentCategory(category: "Покупки", categoryIconStr: "cart"), SpentCategory(category: "Подарки", categoryIconStr: "gift"), SpentCategory(category: "Развлечения", categoryIconStr: "film"), SpentCategory(category: "Автомобиль", categoryIconStr: "car"), SpentCategory(category: "Покупки", categoryIconStr: "cart"), SpentCategory(category: "Подарки", categoryIconStr: "gift"), SpentCategory(category: "Развлечения", categoryIconStr: "film")]
        }
    }
    
    let dataStoreManager = DataStoreManager()
    
    func presentCategory(index: IndexPath) -> SpentCategory {
        return categories[index.row]
    }
    
    func addNewSpent(date: Date, spentCategory: SpentCategory, spentAmount: Int, note: String)  {
        
        dataStoreManager.addNewSpent(date: date, category: spentCategory.category, categoryIcon: spentCategory.categoryIconStr, spentAmount: Int64(spentAmount), note: note)
        
        mainPresenter?.reloadBackVCCollectionView()
        mainPresenter?.reloadTableView()
    }
}
