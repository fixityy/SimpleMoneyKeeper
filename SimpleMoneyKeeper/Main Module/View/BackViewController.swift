//
//  BackViewContro.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.10.2022.
//

import UIKit

class BackViewController: UIViewController, BackViewProtocol {
    
    let presenter: MainPresenterProtocol!
    
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
    
    init(with presenter: MainPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        presenter.setBackDelegate(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dateAndChartCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        presenter.updateFetchResultPredicate(index: 1)

    }
    
    func updatePreviosCell(at newIndexPath: IndexPath) {
        dateAndChartCollectionView.reloadData()
        dateAndChartCollectionView.scrollToItem(at: IndexPath(row: newIndexPath.row + 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func updateNextCell() {
        dateAndChartCollectionView.reloadData()
    }
    
    private func setupViews() {
        view.backgroundColor = Colors.mainAccentColor
        
        view.addSubview(dateAndChartCollectionView)
        makeConstraint()
        
    }
    
    //MARK: Make correct height anchor for all displays, depending on frontVC height
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
        presenter.datesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dateAndChartCollectionView.dequeueReusableCell(withReuseIdentifier: DateAndChartCollectionViewCollectionViewCell.reuseID, for: indexPath) as! DateAndChartCollectionViewCollectionViewCell
        cell.dateLabel.text = presenter.presentDate(at: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: dateAndChartCollectionView.frame.width, height: dateAndChartCollectionView.frame.height)
    }
    
    //Adding next date to dataSource
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let oldIndexPath = collectionView.indexPathsForVisibleItems.first else { return }

        if oldIndexPath.row < indexPath.row && (presenter.datesArray.count - (oldIndexPath.row + 1)) == 1 {
            presenter.addNextDate()
        }
    }
    
    //Adding previous date to dataSource
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let newIndexPath = collectionView.indexPathsForVisibleItems.first else { return }

//        print(newIndexPath.row)
                
        if newIndexPath.row < indexPath.row && newIndexPath.row == 0 {
            presenter.addPreviousDate(at: newIndexPath)
        } else {
            presenter.updateFetchResultPredicate(index: newIndexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

