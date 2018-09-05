//
//  DDayData.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 24..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import CoreData

class DDayData {
    
    var order: Int16? // 순서
    var identifier: String? // ID
    var ddayDate: Date? // 디데이 날짜
    var ddayTitle: String? // 제목
    var notificationTime: Date? // 알림 시각
    var imageExistance: Bool? // 이미지 존재 여부
    var isTodayExtensionSelected: Bool? // 위젯 설정 여부
    
    // 원본 DDayMO 객체를 참조하기 위한 속성
    var objectID: NSManagedObjectID?
    
}
