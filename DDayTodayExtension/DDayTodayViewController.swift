//
//  DDayTodayViewController.swift
//  DDayTodayExtension
//
//  Created by 박수성 on 2018. 1. 19..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import NotificationCenter

class DDayTodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var dday: UILabel!
    @IBOutlet var ddayTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dao = DDayTodayDAO()
        let data = dao.fetch()
        
        if let ddayDate = data.ddayDate {
            self.dday?.text = self.calculateDDay(date: ddayDate)
        } else {
            self.dday?.text = ""
        }
        self.ddayTitle?.text = data.ddayTitle ?? ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "ddayTodayExtension://")
        self.extensionContext?.open(url!, completionHandler: nil)
    }
}
