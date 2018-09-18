//
//  DDayListVC.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMobileAds
import Firebase

class DDayListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GADBannerViewDelegate {
    
    // MARK: - @IBOutlet Property
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Property
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let ud = UserDefaults.standard
    private lazy var dao = DDayDAO()
    
    private var bannerView: GADBannerView! // 구글 애드몬 프로퍼티
    
    // MARK: - override / protocol Method
    override func viewWillAppear(_ animated: Bool) {
        // 앱 첫 실행시 튜토리얼 실행
        if self.ud.bool(forKey: "tutorial") != true {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            self.present(vc!, animated: false)
            return
        }
        
        // 프로모션 동의 여부에 따라 핑거푸시 on/off
        if self.ud.bool(forKey: "setAdPush") == true {
            self.appDelegate.fingerManager?.setEnable(true, nil)
        } else {
            self.appDelegate.fingerManager?.setEnable(false, nil)
        }
        
        self.tableView.allowsSelectionDuringEditing = true
        
        // 코어 데이터에 저장된 데이터를 가져온다.
        self.appDelegate.ddaylist = self.dao.fetch(keyword: self.searchBar.text)
        
        self.tableView.reloadData()
        
        self.editButtonItem.action = #selector(editing(_:))
        if self.appDelegate.ddaylist.count != 0 {
            self.navigationItem.leftBarButtonItem = self.editButtonItem // 편집 버튼 추가
        }
    }
    
    override func viewDidLoad() {
        // 이벤트 기록
        Analytics.logEvent("메인_화면", parameters: ["메인_화면": "메인_화면" as NSObject])
        
        // 검색 바의 키보드에서 리턴 키가 항상 활성화되어 있도록 처리
        searchBar.enablesReturnKeyAutomatically = false
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        adViewDidReceiveAd(bannerView)
        //addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-8516368739403975/5425650916"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.ddaylist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appDelegate.ddaylist[indexPath.row]
        
        // 이미지 속성이 비어 있을 경우 "ddayCell", 아니면 "ddayCellWithImage"
        let cellId = row.imageExistance == false ? "ddayCell" : "ddayCellWithImage"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? DDayCell
        
        // ddayCell의 내용을 구성한다.
        cell?.dday.text = self.calculateDDay(date: row.ddayDate!)
        cell?.ddayTitle?.text = row.ddayTitle
        if row.notificationTime != nil && (row.notificationTime?.timeIntervalSinceNow)! > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd\nahh:mm"
            cell?.notificationTime?.text = formatter.string(from: row.notificationTime!)
            cell?.notificationImage.image = UIImage(named: "notificationIsOn.png")
        } else {
            cell?.notificationTime?.text = "알림 없음"
            cell?.notificationImage.image = UIImage(named: "notificationIsOff.png")
        }
        if row.imageExistance == true {
            cell?.ddayImage?.image = UIImage(data: self.ud.data(forKey: row.identifier!)!)
        }
        
        // cell 객체를 리턴한다.
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.appDelegate.ddaylist[indexPath.row]
        
        var id: String!
        if self.isEditing == true {
            id = "DDayAdd"
        } else {
            id = "DDayRead"
        }
        
        // 상세 화면의 인스턴스를 생성한다.
        let vc = self.storyboard?.instantiateViewController(withIdentifier: id)
        
        // 값을 전달한 다음, 상세 화면으로 이동한다.
        if self.isEditing == true {
            (vc as? DDayAddVC)?.param = row
        } else {
            (vc as? DDayReadVC)?.param = row
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // 목록 편집 형식을 결정하는 함수(삭제 / 수정)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.ddaylist[indexPath.row]
        
        // 코어 데이터에서 삭제한 다음, 배열 내 데이터 및 테이블 뷰 행을 차례로 삭제한다.
        if self.dao.delete(data.objectID!) {
            if self.appDelegate.ddaylist[indexPath.row].imageExistance == true {
                self.ud.removeObject(forKey: self.appDelegate.ddaylist[indexPath.row].identifier!)
                self.ud.synchronize()
            }
            
            self.appDelegate.ddaylist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            self.warningAlert("데이터 삭제 실패")
        }
        
        // 테이블뷰셀 삭제 후 개수가 0이 되면 편집모드 종료하고 leftBarButton 숨김
        if self.appDelegate.ddaylist.count == 0 {
            self.editing(self.editButtonItem)
            self.navigationItem.leftBarButtonItem = nil
        }
        
        // 로컬 알림 삭제
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [data.identifier!])
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard self.searchBar.text == "" else {
            self.warningAlert("검색어가 존재할 경우\n행을 변경 할 수 없습니다.")
            tableView.reloadData()
            return
        }
        
        self.moveItemAtIndex(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
        
        var count = 0
        for object in self.appDelegate.ddaylist {
            guard self.dao.edit(objectID: object.objectID!, order: Int16(count), identifier: object.identifier!, ddayDate: object.ddayDate!, ddayTitle: object.ddayTitle, notificationTime: object.notificationTime, imageExistance: object.imageExistance!, onMoveRow: true) else {
                self.warningAlert("데이터 변경 실패")
                return
            }
            count += 1
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text // 검색 바에 입력된 키워드를 가져온다.
        
        // 키워드를 적용하여 데이터를 검색하고, 테이블 뷰를 갱신한다.
        self.appDelegate.ddaylist = self.dao.fetch(keyword: keyword)
        searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    // MARK: - Method
    // 테이블뷰 row 변경시 리스트 배열 변경 메소드
    private func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        let movedItem = self.appDelegate.ddaylist[fromIndex]
        self.appDelegate.ddaylist.remove(at: fromIndex)
        self.appDelegate.ddaylist.insert(movedItem, at: toIndex)
    }
    
    // MARK: - @objc Method
    @objc private func editing(_ sender: UIBarButtonItem) {
        if self.isEditing == false { // 현재 편집 모드가 아닐 때
            self.isEditing = true
            self.tableView.setEditing(true, animated: true)
            sender.title = "완료"
        } else { // 현재 편집 모드일 때
            self.isEditing = false
            self.tableView.setEditing(false, animated: true)
            sender.title = "편집"
        }
    }
 
    // MARK: - @IBAction Method
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func backToList(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - 구글 애드몹
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func adViewDidReceiveAd(_ bannerView : GADBannerView) {
        // 위와 같이 제약 조건을보고 추가하는 배너를 추가합니다.
        addBannerViewToView(bannerView)
        
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        } else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
}
