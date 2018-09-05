//
//  AppDelegate.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var ddaylist = [DDayData]() // 디데이 데이터를 저장할 배열 변수
    var authorization: Bool? // 알림 승인 정보
    
    // 핑거푸시
    let fingerManager = finger.sharedData()
    private var dicPushContents = [String:String]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // 핑거 푸시 SDK 버전
        print("SdkVer : " + finger.getSdkVer())
        
        // 핑거 푸시
        fingerManager?.setAppKey("VA7QCD1RTLDUCRATD4590CJUF2NNKWBV")
        fingerManager?.setAppScrete("jzbtT4P1wXs5vTMNLZ0VXexcVlZg7SJQ")
        
        // APNS 등록
        registeredForRemoteNotifications(application: application)
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                self.authorization = granted
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        // 페이지 인디케이터 설정을 위한 외형 템플릿 구문
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.backgroundColor = UIColor(red: 248/255, green: 226/255, blue: 64/255, alpha: 1.0)
        
        // 구글 애드몹
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8516368739403975~5275986417")
        
        sleep(1)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    //MARK: - apns 등록
    func registeredForRemoteNotifications(application: UIApplication) {
        //
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            
            //카테고리를 이용한 NotificationAction
            let acceptAction = UNNotificationAction(
                identifier: "com.kissoft.yes",
                title: "확인",
                options: [.foreground]
            )
            let declineAction = UNNotificationAction(
                identifier: "com.kissoft.no",
                title: "닫기",
                options: [.destructive]
            )
            let category = UNNotificationCategory(
                identifier: "fp",
                actions: [acceptAction, declineAction],
                intentIdentifiers: [],
                options:.customDismissAction
            )
            center.setNotificationCategories([category])
            //
            
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                
                if (granted == true){
                    DispatchQueue.main.async(execute: {
                        application.registerForRemoteNotifications()
                    })
                }else{
                    print("User Notification permission denied")
                    if error != nil {
                        print("error : \(error.debugDescription)")
                    }
                }
                
            })
            
        }else{
            
            let types = UIUserNotificationType([.alert, .sound, .badge])
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            
            application.registerForRemoteNotifications()
        }
        
    }
    
    //MARK: - 푸시
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
        
        fingerManager?.registerUser(withBlock: deviceToken, { (posts, error) -> Void in
            
            print("token : " + (self.fingerManager?.getToken())!)
            print("DeviceIdx : " + (self.fingerManager?.getDeviceIdx())!)
            
            if posts != nil {
                print("기기등록: \(posts!)")
            }
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }
            
        })
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    /** ios7 이상*/
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let aps = userInfo["aps"] as? NSDictionary
        
        let cA = aps?["content-available"]
        
        if cA != nil && (cA as AnyObject).intValue == 1{
            
            // 이벤트 기록
            Analytics.logEvent("핑거푸시_수신", parameters: ["핑거푸시_수신": "핑거푸시_수신" as NSObject])
            
            print("content-available : \(String(describing: cA))")
            
            completionHandler(.newData)
            
        }else{
            
            //팝업
            showPopUp(userInfo: userInfo)
            
            //읽음 표시
            checkPush(userInfo)
            
            completionHandler(.noData)
        }
        
    }
    
    //MARK: - iOS10
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 이벤트 기록
        Analytics.logEvent("핑거푸시_수신", parameters: ["핑거푸시_수신": "핑거푸시_수신" as NSObject])
        
        completionHandler([.alert,.sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let strAction = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        if strAction.contains("yes") || strAction.contains("UNNotificationDefaultActionIdentifier") {
            showPopUp(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    //MARK: -
    func showPopUp(userInfo:[AnyHashable: Any]){
        fingerManager?.requestPushContent(withBlock: userInfo) { (posts, error) -> Void in
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }
            
            if posts != nil{
                print("posts : \(posts!)")
                
                for (key, value) in posts! {
                    self.dicPushContents[key as! String] = (value as! String)
                }
                if let urlString = self.dicPushContents["link"] {
                    if let url = URL(string: urlString) {
                        // 이벤트 기록
                        Analytics.logEvent("핑거푸시_클릭", parameters: ["핑거푸시_클릭": "핑거푸시_클릭" as NSObject])
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    /**푸시 오픈 체크하기, 팝업*/
    func checkPush(_ userInfo:[AnyHashable: Any]){
        
        fingerManager?.requestPushCheck(withBlock: userInfo) { (posts, error) -> Void in
            
            if posts != nil {
                print("posts : \(posts!)")
            }
            
            if error != nil {
                print("error : \(error.debugDescription)")
            }
            
        }
        
    }
}

