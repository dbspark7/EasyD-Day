//
//  DDayAddVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import UserNotifications

class DDayAddVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var ddayDate: UILabel!
    @IBOutlet var ddayTitle: UILabel!
    @IBOutlet var notificationTime: UILabel!
    @IBOutlet var ddayImage: UIImageView!
    
    private lazy var dao = DDayDAO()
    
    private var inputDDayDate: Date? // D-Day 날짜
    private var inputNotificationTime: Date? // 알림 시각
    
    var param: DDayData? // 편집 모드시 tableViewCell로부터 받아온 데이터
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.setDDayDate() // 디데이 날짜 설정
        case 1:
            self.setDDayTitle() // 제목 설정
        case 2:
            self.checkAuthorization()
            self.setNotificationTime() // 알림 설정
        case 3:
            self.pick(()) // 이미지 설정
        default:
            ()
        }
    }
    
    func imgPicker(_ source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.ddayImage.image = img
        }
        picker.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        
        // 편집 모드 시 param 프로퍼티로 전달된 데이터
        if self.param != nil {
            // 디데이 날짜
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            self.ddayDate.text = "\(formatter.string(from: (param?.ddayDate)!))\n(\(self.calculateDDay(date: (param?.ddayDate)!)), \(self.calculateDayAfter(date: (param?.ddayDate)!)))"
            self.ddayDate.textColor = UIColor.white
            self.inputDDayDate = param?.ddayDate
            
            // 디데이 제목
            if param?.ddayTitle == "" {
                self.ddayTitle.text = "제목을 입력하세요."
            } else {
                self.ddayTitle.text = param?.ddayTitle
                self.ddayTitle.textColor = UIColor.white
            }
            
            // 알림 시각
            if param?.notificationTime != nil && (param?.notificationTime?.timeIntervalSinceNow)! > 0 {
                formatter.dateFormat = "yyyy년 MM월 dd일 ahh:mm에 알림"
                self.notificationTime.text = formatter.string(from: (param?.notificationTime)!)
                self.notificationTime.textColor = UIColor.white
                self.inputNotificationTime = param?.notificationTime
            }
            
            // 디데이 이미지
            if param?.imageExistance == true {
                let ud = UserDefaults.standard
                self.ddayImage.image = UIImage(data: ud.data(forKey: (param?.identifier)!)!)
            }
        }
    }
    
    // 사진 불러오는 BarButtonItem
    @IBAction func pick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택해주세요.", preferredStyle: .actionSheet)
        
        // 카메라를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "카메라", style: .default) { (_) in
                self.imgPicker(.camera)
            })
        }
        // 저장된 앨범을 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default) { (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        // 포토 라이브러리를 사용할 수 있으면
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default) { (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        // 사진 삭제
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "사진 삭제", style: .destructive) { (_) in
                self.ddayImage.image = nil
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // 저장 BarButtonItem
    @IBAction func save(_ sender: Any) {
        guard self.ddayDate.text != "D-Day 날짜를 입력하세요." else {
            self.warningAlert("D-Day 날짜를 입력하세요.")
            return
        }
        
        let data = DDayData()
        
        // 순서
        data.order = Int16(self.dao.fetch().count)
        
        // D-Day 날짜
        data.ddayDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.inputDDayDate!)!
        
        // D-Day 제목
        data.ddayTitle = (self.ddayTitle.text == "제목을 입력하세요.") ? "" : self.ddayTitle.text
        
        // D-Day 알림 시각
        if let inputNotificationTime = self.inputNotificationTime {
            data.notificationTime = inputNotificationTime
        }
        
        // identifier 설정 (이미지 있을 시 키 공유)
        data.identifier = DateFormatter.setIdentifier(date: Date())
        
        // 편집 후 저장시 기존 이미지 키 삭제
        if param?.imageExistance == true {
            let ud = UserDefaults.standard
            ud.removeObject(forKey: (param?.identifier)!)
            ud.synchronize()
        }
        
        // D-Day 이미지
        if self.ddayImage.image != nil {
            let ud = UserDefaults.standard
            ud.set(UIImagePNGRepresentation(self.ddayImage.image!), forKey: data.identifier!)
            ud.synchronize()
            
            data.imageExistance = true
        } else {
            data.imageExistance = false
        }
        
        _ = self.navigationController?.popViewController(animated: true)
        
        // 알림 설정 시각이 과거일 경우 실행
        if self.inputNotificationTime != nil && (data.notificationTime?.timeIntervalSinceNow)! < 0 {
            data.notificationTime = nil
            self.warningAlert("알림 시각이 과거이므로 '알림 없음'으로 설정됩니다.")
        }
        
        // 로컬 알림 설정
        if data.notificationTime != nil {
            self.setLocalNotification(title: data.ddayTitle!, setTime: data.notificationTime!, identifier: data.identifier!)
        }
        
        // 편집 모드 시 edit 메소드, 디데이 추가 시 insert 메소드 실행
        if self.param != nil {
           // 기존 로컬 알림 삭제
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(param?.identifier)!])
            
            guard self.dao.edit(objectID: (param?.objectID)!, order: data.order!, identifier: data.identifier!, ddayDate: data.ddayDate!, ddayTitle: data.ddayTitle, notificationTime: data.notificationTime, imageExistance: data.imageExistance!, onMoveRow: false) else {
                self.warningAlert("데이터 편집 실패") { () -> Void in
                    self.navigationController?.popViewController(animated: false)
                }
                return
            }
        } else {
            self.dao.insert(data)
        }
    }
    
    // D-Day 로컬 알림 메소드
    private func setLocalNotification(title: String, setTime: Date, identifier: String) -> Void {
        
        // 알림 컨텐츠 정의
        let nContent = UNMutableNotificationContent()
        if let inputDDayDate = self.inputDDayDate {
            nContent.title = "\(self.calculateDDay(date: inputDDayDate))"
        }
        nContent.body = title
        nContent.sound = UNNotificationSound.default()
        nContent.badge = 1
        
        // 발송 시각을 '지금으로부터 *초 형식'으로 변환
        let time = setTime.timeIntervalSinceNow
        
        // 발송 조건 정의
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        // 발송 요청 객체 정의
        let request = UNNotificationRequest(identifier: identifier, content: nContent, trigger: trigger)
        
        // 노티피케이션 센터에 추가
        UNUserNotificationCenter.current().add(request)
    }
    
    // D-Day 날짜 입력 메소드
    private func setDDayDate() {
        let datePicker = DatePickerVC()
        
        let dayAlert = UIAlertController(title: "D-Day 날짜 선택", message: nil, preferredStyle: .alert)
        
        dayAlert.setValue(datePicker, forKeyPath: "contentViewController")
        
        dayAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        dayAlert.addAction(UIAlertAction(title: "입력", style: .default) { (_) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 MM월 dd일"
            self.ddayDate.text = "\(formatter.string(from: datePicker.dateValue))\n(\(self.calculateDDay(date: datePicker.dateValue)), \(self.calculateDayAfter(date: datePicker.dateValue)))"
            self.ddayDate.textColor = UIColor.white
            self.inputDDayDate = datePicker.dateValue
        })
        
        self.present(dayAlert, animated: false)
    }
    
    // D-Day 제목 입력 메소드
    private func setDDayTitle() {
        let alert = UIAlertController(title: "제목", message: nil, preferredStyle: .alert)
        
        alert.addTextField() { (tf) in
            tf.placeholder = "제목을 입력하세요."
            if self.ddayTitle.text != "제목을 입력하세요." {
                tf.text = self.ddayTitle.text
            }
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "입력", style: .default) { (_) in
            if alert.textFields?[0].text == "" {
                self.ddayTitle.text = "제목을 입력하세요."
                self.ddayTitle.textColor = UIColor.lightGray
            } else {
                self.ddayTitle.text = alert.textFields?[0].text
                self.ddayTitle.textColor = UIColor.white
            }
        })
        
        self.present(alert, animated: false)
    }
    
    // 알림 시각 설정 메소드
    private func setNotificationTime() {
        guard self.inputDDayDate != nil else {
            self.warningAlert("D-Day 날짜를 먼저 설정해주세요.")
            return
        }
        
        let timePicker = NotificationTimeVC()
        timePicker.inputDDayDate = self.inputDDayDate
        
        let timeAlert = UIAlertController(title: "D-Day 알림 시각", message: nil, preferredStyle: .alert)
        
        timeAlert.setValue(timePicker, forKeyPath: "contentViewController")
        
        timeAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        timeAlert.addAction(UIAlertAction(title: "입력", style: .default) { (_) in
            let formatter = DateFormatter()
            self.inputNotificationTime = timePicker.timeValue
            formatter.dateFormat = "yyyy년 MM월 dd일 ahh:mm에 알림"
            self.notificationTime.text = formatter.string(from: timePicker.timeValue)
            self.notificationTime.textColor = UIColor.white
        })
        timeAlert.addAction(UIAlertAction(title: "알림 삭제", style: .destructive) { (_) in
            self.notificationTime.text = "로컬 알림 시각을 설정하세요."
            self.notificationTime.textColor = UIColor.lightGray
            self.inputNotificationTime = nil
        })
        
        self.present(timeAlert, animated: false)
    }
    
    // 알림 권한 없을 시 알림창 메소드
    private func checkAuthorization() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard appDelegate.authorization == true else {
            self.warningAlert("알림이 허용되지 않았습니다.\n설정에서 디데이 앱 알림을 켠 후 사용하시기 바랍니다.")
            return
        }
    }
}
