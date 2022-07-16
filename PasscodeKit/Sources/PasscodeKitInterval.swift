//
//  PasscodeInterval.swift
//  app
//
//  Created by StephenFang on 2022/7/16.
//  Copyright © 2022 KZ. All rights reserved.
//

import UIKit

enum PasscodeInterval: Double, CaseIterable {
    case immediately  = 0.0
    case oneMinute    = 1.0
    case fiveMinutes  = 5.0
    case tenMinutes   = 10.0
    case halfAnHour   = 30.0
    case anHour       = 60.0
    
    var localizedDescription: String {
        if self == .immediately {
            return PasscodeKit.vefifyPasscodeImmediately
        } else if self == .anHour {
            return PasscodeKit.vefifyPasscodeAfterOneHour
        } else {
            return String(format: PasscodeKit.vefifyPasscodeAfterMinutes, rawValue)
        }
    }
}

class PasscodeKitInterval: UIViewController {
    
    fileprivate let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var selectedRow = 0
    
    var delegate: PasscodeKitDelegate?
    
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

extension PasscodeKitInterval: UITableViewDataSource {
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

extension PasscodeKitInterval: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PasscodeKit.passcodeInterval(PasscodeInterval.allCases[indexPath.item].rawValue)
        delegate?.passcodeIntervalChanged?()
        
        selectedRow = indexPath.row
        tableView.reloadData()
    }
}
