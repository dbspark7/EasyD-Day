//
//  NotificationTimeViewController.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class NotificationTimeViewController: UIViewController {
    // 데이트 피커 객체 정의
    private let timePicker = UIDatePicker()
    
    // 데이트 피커 객체의 값을 읽어올 연산 프로퍼티
    var timeValue: Date {
        return self.timePicker.date
    }
    
    override func viewDidLoad() {
        // 데이트 피커 모드 - 타임
        self.timePicker.datePickerMode = .time
        
        // 타임 피커 기본 값을 09:00 AM으로 설정
        self.timePicker.setDate(Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: timePicker.date)!, animated: false)
        
        // 타임 피커 뷰 설정
        self.timePicker.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.view.addSubview(self.timePicker)
        self.preferredContentSize = CGSize(width: self.timePicker.frame.width, height: self.timePicker.frame.height + 10)
    }
}

