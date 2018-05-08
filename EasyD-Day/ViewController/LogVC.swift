//
//  LogVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 1. 19..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

public enum LogType: Int16 {
    case create = 0
    case edit = 1
}

extension Int16 {
    func toLogType() -> String {
        switch self {
        case 0:
            return "생성"
        case 1:
            return "수정"
        default:
            return ""
        }
    }
}

class LogVC: UITableViewController {
    var dday: DDayMO! // 전달받은 값
    
    lazy var list: [LogMO]! = {
        return self.dday.logs?.array as! [LogMO]
    }()
    
    override func viewDidLoad() {
        self.preferredContentSize.height = 200
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell") ?? UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "logCell")
        if let regdate = row.regdate {
            cell.textLabel?.text = "\(regdate)에 \(row.type.toLogType())"
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
}
