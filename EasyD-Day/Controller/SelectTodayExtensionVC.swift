//
//  SelectTodayExtensionVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 9. 4..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class SelectTodayExtensionVC: UITableViewController {
    
    // MARK: - Property
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let ud = UserDefaults.standard
    private lazy var dao = DDayDAO()
    
    // MARK: - override / protocol Method
    override func viewWillAppear(_ animated: Bool) {
        // 코어 데이터에 저장된 데이터를 가져온다.
        self.appDelegate.ddaylist = self.dao.fetch()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.ddaylist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appDelegate.ddaylist[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectTodayExtensionCell") as! SelectTodayExtensionCell
        
        if let ddayDate = row.ddayDate, let ddayTitle = row.ddayTitle {
            cell.dday.text = self.calculateDDay(date: ddayDate)
            cell.ddayTitle.text = ddayTitle
        }
        
        cell.todayExtensionSwitch.isOn = row.isTodayExtensionSelected == true ? true : false
        cell.todayExtensionSwitch.addTarget(self, action: #selector(todayExtensionSwitchTapped(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc private func todayExtensionSwitchTapped(_ sender: UISwitch) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        for i in 0..<self.appDelegate.ddaylist.count {
            let cell = self.tableView.cellForRow(at: IndexPath.init(row: i, section: 0)) as! SelectTodayExtensionCell
            let row = self.appDelegate.ddaylist[i]
            
            if i == (indexPath?.row)! {
                _ = self.dao.editTodayExtension(objectID: row.objectID!, isTodayExtensionSelected: true)
            } else {
                cell.todayExtensionSwitch.isOn = false
                _ = self.dao.editTodayExtension(objectID: row.objectID!, isTodayExtensionSelected: false)
            }
        }
    }
}
