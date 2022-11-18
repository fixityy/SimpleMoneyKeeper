//
//  DateAndChartCollectionViewCollectionViewCell.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 05.11.2022.
//

import UIKit
import Charts

class DateAndChartCollectionViewCollectionViewCell: UICollectionViewCell {
    static let reuseID = "DateAndChartCollectionViewCollectionViewCell"
    
    lazy var pieChart: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
                
        chart.holeRadiusPercent = 0.60
        chart.transparentCircleRadiusPercent = 0.65
        
        chart.legend.font = UIFont.systemFont(ofSize: 16)
        chart.legend.verticalAlignment = .bottom
        chart.legend.horizontalAlignment = .center
        chart.legend.form = .circle
        chart.legend.orientation = .horizontal
        chart.legend.formToTextSpace = 8

        chart.extraBottomOffset = -16
        
        //Не отображать названия секций
        chart.drawEntryLabelsEnabled = false
    
//        chart.highlightPerTapEnabled = false
        return chart
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pieChart)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            pieChart.leadingAnchor.constraint(equalTo: leadingAnchor),
            pieChart.trailingAnchor.constraint(equalTo: trailingAnchor),
            pieChart.topAnchor.constraint(equalTo: topAnchor),
            pieChart.bottomAnchor.constraint(equalTo: bottomAnchor)

        ])
    }
}
