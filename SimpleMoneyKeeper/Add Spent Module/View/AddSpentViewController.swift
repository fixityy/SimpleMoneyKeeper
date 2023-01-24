//
//  AddSpentViewController.swift
//  SimpleMoneyKeeper
//
//  Created by Roman Belov on 21.11.2022.
//

import UIKit

class AddSpentViewController: UIViewController, AddSpentViewProtocol {
    
    var presenter: AddSpentPresenterProtocol!
    var isCategoryMenuDropped = false
    var date = Date().localDate()
    var spentCategory: SpentCategory?
    
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var categoryTableViewBottomConstraint: NSLayoutConstraint!
    var categoryTableViewHeightConstraint: NSLayoutConstraint!
    var noteTextViewHeightConstraint: NSLayoutConstraint!
    var datePickerBottomConstraint: NSLayoutConstraint!
    
    lazy var dateLabel: UILabel = {
        var label = UILabel()
        label.text = "Дата"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateTextField: UITextField = {
        var textField = UITextField()
        textField.addBottomBorder(color: .lightGray)
        textField.text = date.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.omitted)
        textField.addTarget(self, action: #selector(dateTextFieldTapped), for: .editingDidBegin)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var categoryLabel: UILabel = {
        var label = UILabel()
        label.text = "Категория"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var categoryTextField: UITextField = {
        var textField = UITextField()
        textField.addBottomBorder(color: .lightGray)
        textField.placeholder = "Выберите категорию"
        textField.addTarget(self, action: #selector(categoryTextFieldTapped), for: .editingDidBegin)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var spentLabel: UILabel = {
        var label = UILabel()
        label.text = "Сумма"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var spentTextField: UITextField = {
        var textField = UITextField()
        textField.addBottomBorder(color: .lightGray)
        textField.placeholder = "Введите потраченную сумму"
        textField.keyboardType = .numberPad
        textField.addDoneButton(title: "Закрыть", target: self, selector: #selector(tappedDoneButton))
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let currencyLabel = UILabel()
        currencyLabel.text = "\u{20BD}"
        currencyLabel.textColor = .lightGray
        currencyLabel.font = .systemFont(ofSize: 24)
        
        textField.rightView = currencyLabel
        textField.rightViewMode = .always
        return textField
    }()
    
    lazy var noteLabel: UILabel = {
        var label = UILabel()
        label.text = "Примечание"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var noteTextView: UITextView = {
        var textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.text = "Добавьте комментарий"
        textView.textColor = UIColor.systemGray3
        textView.delegate = self
        textView.textContainerInset = UIEdgeInsets(top: 12, left: -3, bottom: 4, right: 11)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.addDoneButton(title: "Закрыть", target: self, selector: #selector(tappedDoneButton))
        return textView
    }()
    
    lazy var noteTextViewBottomBorder: UIView = {
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = .lightGray
        bottomBorder.layer.zPosition = 1
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        return bottomBorder
    }()
    
    lazy var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.backgroundColor = Colors.mainAccentColor
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var categoryTextFieldButton: UIButton = {
        var button = UIButton(type: .system)
        button.tintColor = .lightGray
        let eyeImage = UIImage(systemName: "arrowtriangle.down.fill")
        button.setImage(eyeImage, for: .normal)
        button.addTarget(self, action: #selector(categoryTextFieldButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var categoryTableView: UITableView = {
        var tableView = UITableView()
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Colors.tableViewBackground
        tableView.layer.zPosition = 2
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var closeButton: UIButton = {
        var button = UIButton(type: .system)
        button.layer.cornerRadius = 20
        button.backgroundColor = .lightGray
        let buttonImage = UIImage(systemName: "xmark")
        button.tintColor = .white
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.isHidden = true
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    init(with presenter: AddSpentPresenterProtocol) {
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
        
        view.addSubview(dateLabel)
        view.addSubview(dateTextField)
        view.addSubview(categoryLabel)
        view.addSubview(categoryTextField)
        view.addSubview(spentLabel)
        view.addSubview(spentTextField)
        view.addSubview(noteLabel)
        view.addSubview(noteTextView)
        view.addSubview(noteTextViewBottomBorder)
        
        view.addSubview(saveButton)
        view.addSubview(categoryTableView)
        
        view.addSubview(closeButton)
        
        view.addSubview(datePicker)
        makeConstraints()
        
        categoryTextField.rightView = categoryTextFieldButton
        categoryTextField.rightViewMode = .always
        
        let closeBarButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeVC))
        navigationItem.rightBarButtonItem = closeBarButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func makeConstraints() {
        topConstraint = dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60)
        bottomConstraint = saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        
        categoryTableViewBottomConstraint = categoryTableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -8)
        
        categoryTableViewHeightConstraint = categoryTableView.heightAnchor.constraint(equalToConstant: 0)
        
        categoryTableViewBottomConstraint.isActive = false
        categoryTableViewHeightConstraint.isActive = true
        
        noteTextViewHeightConstraint = noteTextView.heightAnchor.constraint(equalToConstant: 48)
        noteTextViewHeightConstraint.priority = UILayoutPriority(rawValue: 500)
        
        datePickerBottomConstraint = datePicker.bottomAnchor.constraint(equalTo: datePicker.topAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            topConstraint,
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            dateTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            dateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateTextField.heightAnchor.constraint(equalToConstant: 48),
            
            datePicker.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 12),
            datePicker.leadingAnchor.constraint(equalTo: dateTextField.leadingAnchor, constant: 40),
            datePicker.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor, constant: -40),
            datePickerBottomConstraint,
            
            categoryLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 12),
            categoryLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            categoryTextField.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            categoryTextField.leadingAnchor.constraint(equalTo: dateTextField.leadingAnchor),
            categoryTextField.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor),
            categoryTextField.heightAnchor.constraint(equalTo: dateTextField.heightAnchor),
            
            spentLabel.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 24),
            spentLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            spentTextField.topAnchor.constraint(equalTo: spentLabel.bottomAnchor, constant: 4),
            spentTextField.leadingAnchor.constraint(equalTo: dateTextField.leadingAnchor),
            spentTextField.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor),
            spentTextField.heightAnchor.constraint(equalTo: dateTextField.heightAnchor),
            
            noteLabel.topAnchor.constraint(equalTo: spentTextField.bottomAnchor, constant: 24),
            noteLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            
            noteTextView.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 4),
            noteTextView.leadingAnchor.constraint(equalTo: dateTextField.leadingAnchor),
            noteTextView.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor),
            noteTextViewHeightConstraint,
            noteTextView.bottomAnchor.constraint(lessThanOrEqualTo: saveButton.topAnchor, constant: -24),
            
            noteTextViewBottomBorder.bottomAnchor.constraint(equalTo: noteTextView.bottomAnchor, constant: -1),
            noteTextViewBottomBorder.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor),
            noteTextViewBottomBorder.trailingAnchor.constraint(equalTo: noteTextView.trailingAnchor),
            noteTextViewBottomBorder.heightAnchor.constraint(equalToConstant: 1),
            
            bottomConstraint,
            saveButton.leadingAnchor.constraint(equalTo: dateTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: dateTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalTo: dateTextField.heightAnchor),
            
            categoryTableView.leadingAnchor.constraint(equalTo: categoryTextField.leadingAnchor),
            categoryTableView.trailingAnchor.constraint(equalTo: categoryTextField.trailingAnchor),
            categoryTableView.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor),
            
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }
    
    @objc private func tappedDoneButton() {
        view.endEditing(true)
    }
    
    @objc private func closeVC() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        
        if categoryTextField.text == "" {
            showAlert(message: "Выберите категорию")
        } else if spentTextField.text == "" {
            showAlert(message: "Введите потраченную сумму")
        } else {
            let spentAmount: Int = Int(spentTextField.text ?? "0") ?? 0
            presenter.addNewSpent(date: date, spentCategory: spentCategory!, spentAmount: spentAmount, note: noteTextView.text ?? "")
            dismiss(animated: true)
        }
    }
    
    @objc private func categoryTextFieldButtonTapped() {
        showOrHideDropDownMenu()
    }
    
    @objc private func categoryTextFieldTapped() {
        showOrHideDropDownMenu()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if noteTextView.isFirstResponder {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                UIView.animate(withDuration: 0.5) {
                    self.topConstraint.constant = -CGFloat(keyboardSize.height / 2)
                    self.bottomConstraint.constant = -CGFloat(keyboardSize.height)
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if noteTextView.isFirstResponder {
            UIView.animate(withDuration: 0.5) {
                self.topConstraint.constant = 60
                self.bottomConstraint.constant = -24
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func dateTextFieldTapped() {
        view.endEditing(true)
        
        if datePickerBottomConstraint.constant == 0 {
            datePicker.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                
                self.datePickerBottomConstraint.constant = 248
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        } else {
            datePicker.isHidden = true
            
            UIView.animate(withDuration: 0.2) {
                
                self.datePickerBottomConstraint.constant = 0
                
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func dateSelected(sender: UIDatePicker) {
        date = sender.date
        dateTextField.text = date.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.omitted)
        datePicker.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            
            self.datePickerBottomConstraint.constant = 0
            
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func showOrHideDropDownMenu() {
        view.endEditing(true)
        if !isCategoryMenuDropped {
            let eyeImage = UIImage(systemName: "arrowtriangle.up.fill")
            categoryTextFieldButton.setImage(eyeImage, for: .normal)
            isCategoryMenuDropped = true
                        
            UIView.animate(withDuration: 0.2) {
                
                self.categoryTableViewBottomConstraint.isActive = true
                self.categoryTableViewHeightConstraint.isActive = false
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        } else {
            let eyeImage = UIImage(systemName: "arrowtriangle.down.fill")
            categoryTextFieldButton.setImage(eyeImage, for: .normal)
            isCategoryMenuDropped = false
                        
            UIView.animate(withDuration: 0.2) {
               
                self.categoryTableViewBottomConstraint.isActive = false
                self.categoryTableViewHeightConstraint.isActive = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Закрыть", style: .cancel)
        alert.addAction(closeAction)
        present(alert, animated: true)
    }

}

extension AddSpentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseId, for: indexPath) as! CategoryTableViewCell
        let category = presenter.presentCategory(index: indexPath)
        if let image = UIImage(systemName: category.categoryIconStr) {
            cell.categoryIcon.image = image
        }
        cell.categoryLabel.text = category.category
        cell.backgroundColor = Colors.tableViewBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        spentCategory = presenter.presentCategory(index: indexPath)
        categoryTextField.text = spentCategory!.category
        
        showOrHideDropDownMenu()
    }
}

//MARK: UITextViewDelegate
extension AddSpentViewController: UITextViewDelegate {
    //убираем placeholder, когда начинается ввод текста
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray3 {
            textView.text = nil
            textView.textColor = .label
        }        
    }
    
    //возвращаем placeholder, если ничего не ввели
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Добавьте комментарий"
            textView.textColor = UIColor.systemGray3
        }
    }
    
        
    func textViewDidChange(_ textView: UITextView) {
        noteTextViewHeightConstraint.constant = textView.contentSize.height + 12
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
