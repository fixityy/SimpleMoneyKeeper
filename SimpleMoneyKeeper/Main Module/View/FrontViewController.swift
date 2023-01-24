//
//  FrontViewController.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 22.10.2022.
//

import UIKit
import CoreData

class FrontViewController: UIViewController, FrontViewProtocol {
    
    let presenter: MainPresenterProtocol!
        
    lazy var tableView: UITableView = {
        var table = UITableView()
        table.register(SpentTableViewCell.self, forCellReuseIdentifier: SpentTableViewCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.sectionHeaderTopPadding = 0
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    lazy var addButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 48)
        button.contentVerticalAlignment = .bottom
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.mainAccentColor
        button.layer.cornerRadius = 32
        button.layer.zPosition = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
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
        
        setupView()

    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 40
        view.addSubview(tableView)
        view.addSubview(addButton)
        makeConstraints()
        
        presenter.setFrontDelegate(delegate: self)
        presenter.fetchResultController.delegate = self
        presenter.performFetch()
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: 64),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        presenter.presentAddSpentVC(viewController: self)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension FrontViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.fetchResultController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = presenter.fetchResultController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpentTableViewCell.reuseId, for: indexPath) as! SpentTableViewCell
        
        let spent = presenter.presentSpent(index: indexPath)
        if let imageStr = spent.categoryIconStr, let image = UIImage(systemName: imageStr) {
            cell.categoryIcon.image = image
        }
        cell.categoryLabel.text = spent.category
        cell.amountlabel.text = "\(Int(spent.spentAmount).stringWithSpaceEveryThreeDigits()) \u{20BD}"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = presenter.fetchResultController.sections?[section]
        let spent = sectionInfo?.objects?.first as? Spent
        return spent?.dateStr?.formatted(date: .long, time: .omitted)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = presenter.presentSpent(index: indexPath)
            presenter.dataStoreManager.context.delete(object)
            presenter.dataStoreManager.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(presenter.fetchResultController.object(at: indexPath))
    }
}

//MARK: NSFetchedResultsControllerDelegate

extension FrontViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        let section = IndexSet(integer: sectionIndex)

        switch type {
        case .delete:
            tableView.deleteSections(section, with: .automatic)
            presenter.reloadBackVCCollectionView()
            
        case .insert:
            tableView.insertSections(section, with: .automatic)
            presenter.reloadBackVCCollectionView()

        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            if let indexPath = indexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
                presenter.reloadBackVCCollectionView()
            }
        case .delete:
            if let indexPath = indexPath, tableView.numberOfRows(inSection: indexPath.section) > 1 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                presenter.reloadBackVCCollectionView()
            }
        default:
            break
        }
    }
}
