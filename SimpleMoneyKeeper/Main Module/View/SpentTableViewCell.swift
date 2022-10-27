//
//  SpentTableViewCell.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 27.10.2022.
//

import UIKit

class SpentTableViewCell: UITableViewCell {
    
    lazy var containerImageView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainAccentColor
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var categoryIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var amountlabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .label
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static let reuseId = "SpentTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerImageView)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountlabel)
        containerImageView.addSubview(categoryIcon)
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            containerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerImageView.widthAnchor.constraint(equalTo: containerImageView.heightAnchor),
            containerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            categoryIcon.topAnchor.constraint(equalTo: containerImageView.topAnchor, constant: 8),
            categoryIcon.bottomAnchor.constraint(equalTo: containerImageView.bottomAnchor, constant: -8),
            categoryIcon.leadingAnchor.constraint(equalTo: containerImageView.leadingAnchor, constant: 8),
            categoryIcon.trailingAnchor.constraint(equalTo: containerImageView.trailingAnchor, constant: -8),
            
            categoryLabel.leadingAnchor.constraint(equalTo: containerImageView.trailingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: amountlabel.leadingAnchor, constant: -8),
            categoryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            amountlabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountlabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
}
