//
//  DatePickerVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 1. 16..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class DatePickerVC: UIViewController {
    // 데이트 피커 객체 정의
    private let datePicker = UIDatePicker()
    
    // 데이트 피커 객체의 값을 읽어올 연산 프로퍼티
    var dateValue: Date {
        return self.datePicker.date
    }
    
    override func viewDidLoad() {
        // 데이트 피커 모드 - 데이트
        self.datePicker.datePickerMode = .date
        
        // 타임 피커 기본 값을 당일로 설정
        self.datePicker.setDate(Date(), animated: false)
        // 타임 피커 뷰 설정
        self.datePicker.frame = CGRect(x: 0, y: 0, width: 240, height: 200)
        self.view.addSubview(self.datePicker)
        self.preferredContentSize = CGSize(width: self.datePicker.frame.width, height: self.datePicker.frame.height + 10)
    }
}
