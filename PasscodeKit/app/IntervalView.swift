//
//  IntervalViewController.swift
//  Example
//
//  Created by StephenFang on 2022/7/8.
//  Copyright © 2022 KZ. All rights reserved.
//

import UIKit

class IntervalViewController: UIViewController {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
    fileprivate var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Require Password"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedRow = PasscodeInterval.allCases.firstIndex(where: { $0.rawValue == PasscodeKit.passcodeInterval()
        }) {
            self.selectedRow = selectedRow
        }
        tableView.selectRow(at: IndexPath(item: selectedRow, section: 0), animated: false, scrollPosition: .top)
    }
}

extension IntervalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PasscodeInterval.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: "cell") }

        cell.selectionStyle = .none
        cell.textLabel?.text = PasscodeInterval.allCases[indexPath.item].localizedDescription
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none

        return cell
    }
}

extension IntervalViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PasscodeKit.passcodeInterval(PasscodeInterval.allCases[indexPath.item].rawValue)
        
        selectedRow = indexPath.row
        tableView.reloadData()
    }
}
