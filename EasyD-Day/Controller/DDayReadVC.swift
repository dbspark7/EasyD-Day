//
//  DDayReadVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 1. 16..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import Firebase

class DDayReadVC: UIViewController {
    
    // MARK: - @IBOutlet Property
    @IBOutlet var dday: UILabel!
    @IBOutlet var ddayTitle: UILabel!
    @IBOutlet var ddayDate: UILabel!
    @IBOutlet var notificationTime: UILabel!
    @IBOutlet var ddayImage: UIImageView!
    
    // MARK: - Property
    var param: DDayData?
    
    // MARK: - override Method
    override func viewDidLoad() {
        // 이벤트 기록
        Analytics.logEvent("확인_화면", parameters: ["확인_화면": "확인_화면" as NSObject])
        
        self.setup()
    }
    
    // MARK: - Method
    private func setup() {
        // 디데이
        self.dday.text = self.calculateDDay(date: (param?.ddayDate)!)
        
        // 제목
        self.ddayTitle.text = param?.ddayTitle
        
        // 디데이 날짜
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        self.ddayDate.text = formatter.string(from: (param?.ddayDate)!)
        
        // 알림
        if param?.notificationTime != nil && (param?.notificationTime?.timeIntervalSinceNow)! > 0 {
            formatter.dateFormat = "yyyy년 MM월 dd일 ahh시 mm분"
            self.notificationTime.text = formatter.string(from: (param?.notificationTime)!)
        } else {
            self.notificationTime.text = "없음"
        }
        
        // 이미지
        if param?.imageExistance == true {
            let ud = UserDefaults.standard
            self.ddayImage.image = UIImage(data: ud.data(forKey: (param?.identifier)!)!)
        }
    }
    
    // MARK: - @IBAction Method
    @IBAction func logs(_ sender: Any) {
        let coreDataStack = CoreDataStack(modelName: "EasyD-Day1.1")
        let object = coreDataStack.mainQueueContext.object(with: (param?.objectID)!)
        
        let lvc = LogVC()
        lvc.dday = object as! DDayMO
        
        let alert = CustomAlertController(title: "로그", message: nil, preferredStyle: .alert)
        
        alert.setValue(lvc, forKeyPath: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        self.present(alert, animated: false)
    }
}
