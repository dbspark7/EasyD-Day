//
//  Utils.swift
//  EasyD-Day
//
//  Created by 박수성 on 2018. 1. 23..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}

// 알림창 Extension
extension UIViewController {
    func warningAlert(_ message: String, completion: (()->Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            completion?() // completion 매개변수의 값이 nil이 아닐 때에만 실행되도록
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}

// D-Day 계산기
extension UIViewController {
    func calculateDDay(date: Date) -> String {
        let time = date.timeIntervalSinceNow / (60 * 60 * 24)
        if time <= 0 && time > -1 {
            return "D-Day"
        } else if time <= -1 {
            return "D+\(-Int(time))"
        } else {
            return "D\(-Int(time)-1)"
        }
    }
}

// n일째 계산기
extension UIViewController {
    func calculateDayAfter(date: Date) -> String {
        let time = date.timeIntervalSinceNow / (60 * 60 * 24)
        if time <= 0 && time > -1 {
            return "오늘"
        } else if time <= -1 {
            return "오늘로부터 \(-Int(time))일 전"
        } else {
            return "오늘로부터 \(Int(time)+2)일째 되는 날"
        }
    }
}

// identifier formatter
extension DateFormatter {
    static func setIdentifier(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_hhmmss"
        return formatter.string(from: date)
    }
}
