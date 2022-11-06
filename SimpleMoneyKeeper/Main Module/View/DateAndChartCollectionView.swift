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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let oldIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        
        
        
        if oldIndexPath.row < indexPath.row && (dates.count - (oldIndexPath.row + 1)) == 1 {
            dates.insert(addOrSubtractMonth(month: increaseMonth), at: dates.endIndex)
            increaseMonth += 1
            collectionView.reloadData()
        } else if oldIndexPath.row > indexPath.row && oldIndexPath.row == 1 {
            
            print("Влево \(count)")
            count += 1
            print("Old indexPath: \(oldIndexPath)\n New indexPath\(indexPath)")

            
            
            collectionView.performBatchUpdates {
                dates.insert(addOrSubtractMonth(month: decreaseMonth), at: 0)
                decreaseMonth -= 1
                collectionView.reloadData()
                UIView.performWithoutAnimation {
                    collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
            } completion: { _ in
                collectionView.scrollToItem(at: IndexPath(row: oldIndexPath.row + 1, section: 0), at: .centeredHorizontally, animated: false)
            }


//            collectionView.scrollToItem(at: IndexPath(row: oldIndexPath.row + 2, section: 0), at: .centeredHorizontally, animated: false)
            
            
//            collectionView.performBatchUpdates {
//                dates.insert(addOrSubtractMonth(month: decreaseMonth), at: 0)
//                decreaseMonth -= 1
//                collectionView.insertItems(at: [IndexPath(row: 1, section: 0)])
//                collectionView.reloadData()
//                collectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
//            } completion: { _ in
//                collectionView.scrollToItem(at: IndexPath(row: oldIndexPath.row + 1, section: 0), at: .centeredHorizontally, animated: true)
//            }

        }
        
//        print(dates)
//        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    //MARK: temp, delete after
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }
}

