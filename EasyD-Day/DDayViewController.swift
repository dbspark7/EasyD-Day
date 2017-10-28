//
//  DDayViewController.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import UserNotifications

class DDayViewController: UITableViewController {
    
    // 앱 델리게이트 객체의 참조 정보를 읽어온다.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // D-Day 알림 메소드
    func ddayAlert(message: String, setTime: Date, identifier: String) -> Void {
        
        // 알림 컨텐츠 정의
        let nContent = UNMutableNotificationContent()
        nContent.body = message
        nContent.title = "D-Day"
        nContent.sound = UNNotificationSound.default()
        
        // 발송 시각을 '지금으로부터 *초 형식'으로 변환
        let time = setTime.timeIntervalSinceNow
        
        // 발송 조건 정의
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        // 발송 요청 객체 정의
        let request = UNNotificationRequest(identifier: identifier, content: nContent, trigger: trigger)
        
        // 노티피케이션 센터에 추가
        UNUserNotificationCenter.current().add(request)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.appDelegate.ddaylist.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ddaylist 배열 데이터에서 주어진 행에 맞는 데이터를 꺼낸다.
        let row = self.appDelegate.ddaylist[indexPath.row]
        
        // 재사용 큐로부터 프로토타입 셀의 인스턴스를 전달받는다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ddayCell") as! DDayCell
        
        // ddayCell의 내용을 구성한다.
        let time = (row.date?.timeIntervalSinceNow)! / (60 * 60 * 24)
        if time <= 0 && time > -1 {
            cell.dday.text = "D-Day"
        } else if time <= -1 {
            cell.dday.text = "D+\(-Int(time))"
        } else {
            cell.dday.text = "D\(-Int(time)-1)"
        }
        
        cell.content?.text = row.message
        
        if row.alertIsOn! && (row.timeAlert?.timeIntervalSinceNow)! > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd ahh:mm에 알림"
            cell.notification?.text = formatter.string(from: row.timeAlert!)
            
            self.ddayAlert(message: row.message!, setTime: row.timeAlert!, identifier: String(indexPath.row))
        } else {
            cell.notification?.text = "알림 없음"
        }
        
        // cell 객체를 리턴한다.
        return cell
    }
    
    override func viewDidLoad() {
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        if self.appDelegate.ddaylist.count != 0 {
            self.navigationItem.leftBarButtonItem = self.editButtonItem // 편집 버튼 추가
        }
    }
    
    // 목록 편집 형식을 결정하는 함수(삭제 / 수정)
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.appDelegate.ddaylist.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        if self.appDelegate.ddaylist.count == 0 {
            self.navigationItem.leftBarButtonItem = nil
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(indexPath.row)])
    }
    
    @IBAction func backToList(_ segue: UIStoryboardSegue) {
        
    }
}
