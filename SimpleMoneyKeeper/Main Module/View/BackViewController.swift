//
//  BackViewContro.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.10.2022.
//

import UIKit

class BackViewController: UIViewController {
    
    var dates: [Date]!
    
    //MARK: temp, delete after
    var decreaseMonth = -2
    var increaseMonth = 2    
    
    lazy var dateAndChartCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = Colors.mainAccentColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DateAndChartCollectionViewCollectionViewCell.self, forCellWithReuseIdentifier: DateAndChartCollectionViewCollectionViewCell.reuseID)
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dateAndChartCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)

    }
    
    private func setupViews() {
        view.backgroundColor = Colors.mainAccentColor
        
        view.addSubview(dateAndChartCollectionView)
        makeConstraint()
        
        dates = [addOrSubtractMonth(month: -1), addOrSubtractMonth(month: 0), addOrSubtractMonth(month: 1)]
    }

    
    //MARK: temp, delete after
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }
    
    private func makeConstraint() {
        NSLayoutConstraint.activate([
            dateAndChartCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateAndChartCollectionView.heightAnchor.constraint(equalToConstant: 300),
            dateAndChartCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateAndChartCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])
        
    }
}


extension BackViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dateAndChartCollectionView.dequeueReusableCell(withReuseIdentifier: DateAndChartCollectionViewCollectionViewCell.reuseID, for: indexPath) as! DateAndChartCollectionViewCollectionViewCell
        cell.dateLabel.text = dates[indexPath.row].formatted()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: dateAndChartCollectionView.frame.width, height: dateAndChartCollectionView.frame.height)
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
}

