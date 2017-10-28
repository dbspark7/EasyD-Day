//
//  DDayAddViewController.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import UserNotifications

class DDayAddViewController: UITableViewController {
    
    @IBOutlet weak var messageInput: UILabel!
    @IBOutlet weak var notificationTime: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var alertIsOn: UISwitch!
    
    let timePicker = NotificationTimeViewController()
    
    var authorization: Bool?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.inputMessage()
        }
    }
    
    // D-Day 메세지 입력 메소드
    func inputMessage() {
        let messageAlert = UIAlertController(title: "D-Day 메시지", message: nil, preferredStyle: .alert)
        
        messageAlert.addTextField() { (tf) in
            tf.placeholder = "메세지를 입력하세요."
            if self.messageInput.text != "메세지를 입력하세요." {
                tf.text = self.messageInput.text
            }
        }
        
        messageAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        messageAlert.addAction(UIAlertAction(title: "입력", style: .default) { (_) in
            self.messageInput.text = messageAlert.textFields?[0].text
        })
        
        self.present(messageAlert, animated: false)
    }
    
    // 알림 시각 설정 메소드
    func inputAlertTime(_ sender: UISwitch) {
        let timeAlert = UIAlertController(title: "D-Day 알림 시각", message: nil, preferredStyle: .alert)
        
        timeAlert.setValue(timePicker, forKeyPath: "contentViewController")
        
        timeAlert.addAction(UIAlertAction(title: "취소", style: .cancel) { (_) in
            sender.setOn(false, animated: true)
        })
        timeAlert.addAction(UIAlertAction(title: "입력", style: .default) { (_) in
            let formatter = DateFormatter()
            formatter.dateFormat = "ahh:mm에 알림"
            self.notificationTime.text = formatter.string(from: self.timePicker.timeValue)
        })
        
        self.present(timeAlert, animated: false)
    }
    
    // 알림 권한 없을 시 알림창 메소드
    func checkAuthorization() {
        guard authorization == true else {
            let authorizationAlert = UIAlertController(title: "Warning!", message: "알림이 허용되지 않았습니다.\n설정에서 알림을 켠 후 사용하시기 바랍니다.", preferredStyle: .alert)
            
            authorizationAlert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
                self.navigationController?.popViewController(animated: true)
            })
            
            self.present(authorizationAlert, animated: false)
            return
        }
    }
    
    override func viewDidLoad() {
        // 알림 권한 확인
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.authorization = true
            } else {
                self.authorization = false
            }
        }
    }
    
    @IBAction func notification(_ sender: UISwitch) {
        if sender.isOn {
            self.checkAuthorization()
            self.inputAlertTime(sender)
        } else {
            self.notificationTime.text = "알림 없음"
        }
    }
    
    @IBAction func save(_ sender: Any) {
        // DDayData 객체를 생성하고, 데이터를 담는다.
        let data = DDayData()
        
        // D-Day 날짜
        data.date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.datePicker.date)!
        print("D-Day 날짜 : \(data.date!)")
        
        // D-Day 메세지
        data.message = (self.messageInput.text == "메세지를 입력하세요.") ? "" : self.messageInput.text
        
        // D-Day 알림 시각
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour = Int(formatter.string(from: self.timePicker.timeValue))
        formatter.dateFormat = "mm"
        let minute = Int(formatter.string(from: self.timePicker.timeValue))
        data.timeAlert = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: data.date!)
        print("D-Day 알림 시각 : \(data.timeAlert!)")
        
        // 앱 델리게이트 객체를 읽어온 다음, vclist 배열에 VCData 객체를 추가한다.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.ddaylist.append(data)
        
        // 작성폼 화면을 종료하고, 이전 화면으로 돌아간다.
        _ = self.navigationController?.popViewController(animated: true)
        
        // 알림 사용 여부
        data.alertIsOn = self.alertIsOn.isOn
        guard (data.timeAlert?.timeIntervalSinceNow)! > 0 else {
            if self.alertIsOn.isOn {
                let beforeTimeAlert = UIAlertController(title: "Warning!", message: "알림 시각이 과거이므로 '알림 없음'으로 설정됩니다.", preferredStyle: .alert)
                
                beforeTimeAlert.addAction(UIAlertAction(title: "확인", style: .default))
                
                self.present(beforeTimeAlert, animated: false)
            }
            data.alertIsOn = false
            return
        }
    }
}
