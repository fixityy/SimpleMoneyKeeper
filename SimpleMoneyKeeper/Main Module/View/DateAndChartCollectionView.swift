//
//  DateAndChartCollectionView.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 05.11.2022.
//

import UIKit

class DateAndChartCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dates = [Date]()
    
    //MARK: temp, delete after
    var decreaseMonth = -2
    var increaseMonth = 2
    var count = 0

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        
        backgroundColor = Colors.mainAccentColor
        translatesAutoresizingMaskIntoConstraints = false
        register(DateAndChartCollectionViewCollectionViewCell.self, forCellWithReuseIdentifier: DateAndChartCollectionViewCollectionViewCell.reuseID)
        
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: DateAndChartCollectionViewCollectionViewCell.reuseID, for: indexPath) as! DateAndChartCollectionViewCollectionViewCell
        cell.dateLabel.text = dates[indexPath.row].formatted()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: frame.width, height: frame.height)
    }
    
    //Adding next date to dataSource
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let oldIndexPath = collectionView.indexPathsForVisibleItems.first else { return }

        if oldIndexPath.row < indexPath.row && (dates.count - (oldIndexPath.row + 1)) == 1 {
            dates.insert(addOrSubtractMonth(month: increaseMonth), at: dates.endIndex)
            increaseMonth += 1
            collectionView.reloadData()
        }
    }
    
    //Adding previous date to dataSource
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let newIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        
        if newIndexPath.row < indexPath.row && newIndexPath.row == 0 {
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.dates.insert(self.addOrSubtractMonth(month: self.decreaseMonth), at: 0)
                self.decreaseMonth -= 1
                
                DispatchQueue.main.async {
                    collectionView.reloadData()
                    collectionView.scrollToItem(at: IndexPath(row: newIndexPath.row + 1, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    //MARK: temp, delete after
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }
}

