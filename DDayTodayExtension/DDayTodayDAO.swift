//
//  DDayTodayDAO.swift
//  DDayTodayExtension
//
//  Created by 박수성 on 2018. 1. 20..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import Foundation
import CoreData

class DDayTodayDAO {
    // 저장된 D-Day 리스트를 불러오는 메소드
    func fetch() -> DDayTodayData {
        let coreDataStack = CoreDataStack(modelName: "EasyD-Day")
        let data = DDayTodayData()
        
        // 요청 객체 생성
        let fetchRequest: NSFetchRequest<DDayMO> = DDayMO.fetchRequest()
        
        // 정렬 속성 설정
        let sort = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let resultset = try coreDataStack.mainQueueContext.fetch(fetchRequest)
            
            for record in resultset {
                data.ddayDate = record.ddayDate
                data.ddayTitle = record.ddayTitle
                break
            }
        } catch let e as NSError {
            NSLog("An error has occurred: %s", e.localizedDescription)
            data.ddayTitle = "데이터 불러오기 실패"
        }
        return data
    }
}
