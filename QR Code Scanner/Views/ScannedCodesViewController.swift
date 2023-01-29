//
//  ScannedCodesViewController.swift
//  QR Code Scanner
//
//  Created by amrmahdy on 02/01/2023.
//

import Foundation
import UIKit

class ScannedCodesViewController: UIViewController {
    var newScannedCode: ScannedCodesViewModel? {
        set {
            guard let newValue = newValue else { return }
            data.insert(newValue, at: 0)
        } get {
            return self.newScannedCode
        }
    }
    private var data: [ScannedCodesViewModel] {
        get {
            guard let storedData = UserDefaults.standard.object(forKey: "scannedCodes") as? Data else { return [] }
            guard let decodedData = try? JSONDecoder().decode([ScannedCodesViewModel].self, from: storedData) else { return []}
            return decodedData
        } set {
            guard let encodedData = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(encodedData, forKey: "scannedCodes")
            UserDefaults.standard.synchronize()
        }
    }
    //    MARK: - UI properities
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScannedCodesTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
       return tableView
    }()
    private lazy var clearAllBtn: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "trash")
        configuration.imagePadding = 8
        configuration.imagePlacement = .trailing
        button.configuration = configuration
        button.tintColor = .systemRed
        button.setTitle("Clear All", for: .normal)
        button.addTarget(self, action: #selector(clearAllTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var closeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .black, scale: .large)), for: .normal)
        button.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        button.tintColor = .darkGray
        return button
    }()
    //    MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
    }
    //    MARK:  - Methods
    private func setupConstraints() {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.alignment = .center
        sv.addArrangedSubview(clearAllBtn)
        sv.addArrangedSubview(closeBtn)
        
        view.addSubview(sv)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            sv.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            sv.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: sv.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    //    MARK:  - Action methods
    @objc private func clearAllTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "scannedCodes")
        tableView.reloadData()
    }
    @objc private func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    private func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }

}
//    MARK: - Table View Delegate & Datasource
extension ScannedCodesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell  = tableView.dequeueReusableCell(withIdentifier: "cell") as? ScannedCodesTableViewCell else {
            print("cell")
            return UITableViewCell()}
        cell.selectionStyle = .none
        cell.configure(with: data[indexPath.row % data.count])
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            print(suggestedActions)
//            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) {
//                action in
//                print("Delete")
//            }
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) {
                action in
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.data[indexPath.row].information
                print("Copy")
            }
            let safariAction = UIAction(title: "Open in Safari", image: UIImage(systemName: "safari")) {
                action in
                self.openURL(url: self.data[indexPath.row].information)
            }
            return UIMenu(title: "Actions",children: [safariAction, copyAction])
        })
    }
}
