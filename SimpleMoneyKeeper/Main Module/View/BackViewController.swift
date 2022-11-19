//
//  BackViewContro.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.10.2022.
//

import UIKit
import Charts

class BackViewController: UIViewController, BackViewProtocol {
    
    let presenter: MainPresenterProtocol!
    var pieChartLastHighlited: Highlight?
    
    var dateStr = NSMutableAttributedString()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dateAndChartCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func updatePreviosCell(at newIndexPath: IndexPath) {
        dateAndChartCollectionView.reloadData()
        dateAndChartCollectionView.scrollToItem(at: IndexPath(row: newIndexPath.row + 1, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    func updateNextCell() {
        dateAndChartCollectionView.reloadData()
    }
    
    func reloadCollectionView() {
        dateAndChartCollectionView.reloadData()
    }
    
    private func setupViews() {
        view.backgroundColor = Colors.mainAccentColor
        
        view.addSubview(dateAndChartCollectionView)
        makeConstraint()
        
        presenter.performFetchPieChart()
        presenter.setBackDelegate(delegate: self)

        dateStr = presenter.presentDate(at: 1)
    }
    
    //MARK: Make correct height anchor for all displays, depending on frontVC height
    private func makeConstraint() {
        NSLayoutConstraint.activate([
            dateAndChartCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateAndChartCollectionView.heightAnchor.constraint(equalToConstant: (view.frame.size.height / 2.55)),
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
                
        cell.pieChart.delegate = self
        
        cell.pieChart.holeColor = Colors.mainAccentColor
        cell.pieChart.data = presenter.presentPieChartData()
        cell.pieChart.centerAttributedText = presenter.presentDate(at: indexPath.row)
        
        dateStr = presenter.presentDate(at: indexPath.row)

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
        
//        guard let cell = cell as? DateAndChartCollectionViewCollectionViewCell else { return }
//        cell.pieChart.animate(xAxisDuration: 1)
    }
    
    //Adding previous date to dataSource
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let newIndexPath = collectionView.indexPathsForVisibleItems.first else { return }

        dateStr = presenter.presentDate(at: newIndexPath.row)

//        print(newIndexPath.row)
                
        if newIndexPath.row < indexPath.row && newIndexPath.row == 0 {
            presenter.addPreviousDate(at: newIndexPath)
        } else {
            presenter.updateFetchResultPredicate(index: newIndexPath.row)
        }
        
        guard let cell = cell as? DateAndChartCollectionViewCollectionViewCell else { return }
        cell.pieChart.highlightValues(nil)
        cell.pieChart.centerAttributedText = dateStr
        pieChartLastHighlited = nil
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension BackViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let pieChart = chartView as? PieChartView, let pieChartDataEntry = entry as? PieChartDataEntry else { return }
        

        if highlight == pieChartLastHighlited {
            //unhighlight all sections
            pieChart.highlightValues(nil)
            pieChart.centerAttributedText = dateStr
            pieChartLastHighlited = nil
        } else {
            pieChartLastHighlited = highlight
            
            let str = (pieChartDataEntry.label ?? "") + ":\n" + Int(pieChartDataEntry.y.rounded()).stringWithSpaceEveryThreeDigits() + "  \u{20BD}"
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let centerText = NSMutableAttributedString(string: str)
            centerText.setAttributes([.font : UIFont.systemFont(ofSize: 18), .paragraphStyle: paragraph], range: NSRange(location: 0, length: centerText.length))
            
            pieChart.centerAttributedText = centerText
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        guard let pieChart = chartView as? PieChartView else { return }
        
        pieChart.centerAttributedText = dateStr
    }
}

