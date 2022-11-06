//
//  FrontViewController.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 22.10.2022.
//

import UIKit
import CoreData

class FrontViewController: UIViewController {
    
    let dataStoreManager = DataStoreManager()
    
    lazy var fetchResultController: NSFetchedResultsController<Spent> = {
        let fetchRequest = Spent.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Spent.dateStr), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchResultController = NSFetchedResultsController<Spent>(fetchRequest: fetchRequest, managedObjectContext: dataStoreManager.context, sectionNameKeyPath: #keyPath(Spent.dateStr), cacheName: nil)
        
        fetchResultController.delegate = self
        
        return fetchResultController
    }()
        
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(addButton)
        makeConstraints()
        
        
        do {
            try fetchResultController.performFetch()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: 64),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    @objc private func addButtonTapped() {
        
        let randomNumber = Double.random(in: -350000...350000)
        
        let date = Date(timeIntervalSinceNow: randomNumber)
        
        dataStoreManager.addNewSpent(date: date, category: "Car", categoryIcon: "car", spentAmount: Int64.random(in: 100...350000))
        tableView.reloadData()
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension FrontViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchResultController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SpentTableViewCell.reuseId, for: indexPath) as! SpentTableViewCell
        if let imageStr = fetchResultController.object(at: indexPath).categoryIconStr, let image = UIImage(systemName: imageStr) {
            cell.categoryIcon.image = image
        }
        cell.categoryLabel.text = fetchResultController.object(at: indexPath).category
        cell.amountlabel.text = "\(fetchResultController.object(at: indexPath).spentAmount) \u{20BD}"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultController.sections?[section].name
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = fetchResultController.object(at: indexPath)
            dataStoreManager.context.delete(object)
            dataStoreManager.saveContext()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(fetchResultController.object(at: indexPath))
    }
}

//MARK: NSFetchedResultsControllerDelegate

extension FrontViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        let section = IndexSet(integer: sectionIndex)

        switch type {
            case .delete:
                tableView.deleteSections(section, with: .automatic)
            case .insert:
                tableView.insertSections(section, with: .automatic)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            if let indexPath = indexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath, tableView.numberOfRows(inSection: indexPath.section) > 1 {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
}
