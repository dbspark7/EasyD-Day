//
//  NotificationTimeVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class NotificationTimeVC: UIViewController {
    // 데이트 피커 객체 정의
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    
    var inputDDayDate: Date? // 전달받은 D-Day 날짜
    
    // 데이트 피커 객체의 값을 읽어올 연산 프로퍼티
    var timeValue: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour = Int(formatter.string(from: self.timePicker.date))
        formatter.dateFormat = "mm"
        let minute = Int(formatter.string(from: self.timePicker.date))
        return Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: self.datePicker.date)!
    }
    
    override func viewDidLoad() {
        // 데이트 피커 모드
        self.datePicker.datePickerMode = .date
        self.timePicker.datePickerMode = .time
        
        // 데이트 피커 기본 값 설정
        if self.inputDDayDate != nil {
            self.datePicker.setDate(self.inputDDayDate!, animated: false)
        }
        
        // 타임 피커 기본 값을 09:00 AM으로 설정
        self.timePicker.setDate(Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: self.datePicker.date)!, animated: false)
        
        // 데이트 피커 뷰 설정
        self.datePicker.frame = CGRect(x: 0, y: 0, width: 240, height: 150)
        self.view.addSubview(self.datePicker)
        
        // 타임 피커 뷰 설정
        self.timePicker.frame = CGRect(x: 0, y: 150, width: 240, height: 150)
        self.view.addSubview(self.timePicker)
        self.preferredContentSize = CGSize(width: self.timePicker.frame.width, height: self.timePicker.frame.height * 2 + 10)
    }
}
