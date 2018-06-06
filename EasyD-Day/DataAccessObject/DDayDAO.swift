//
//  DDayDAO.swift
//  EasyD-Day
//
//  Created by 박수성 on 2017. 10. 28..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit
import CoreData

class DDayDAO: UIViewController {
    
    let coreDataStack = CoreDataStack(modelName: "EasyD-Day")
    
    // 저장된 D-Day 리스트를 불러오는 메소드
    func fetch(keyword text: String? = nil) -> [DDayData] {
        var ddaylist = [DDayData]()
        
        // 요청 객체 생성
        let fetchRequest: NSFetchRequest<DDayMO> = DDayMO.fetchRequest()
        
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "ddayTitle CONTAINS[c] %@", t)
        }
        
        // 정렬 속성 설정
        let sort = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let resultset = try self.coreDataStack.mainQueueContext.fetch(fetchRequest)
            
            for record in resultset {
                let data = DDayData()
                
                data.order = record.order
                data.identifier = record.identifier
                data.ddayDate = record.ddayDate
                data.ddayTitle = record.ddayTitle
                data.notificationTime = record.notificationTime
                data.imageExistance = record.imageExistance
                
                data.objectID = record.objectID
                
                ddaylist.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occurred: %s", e.localizedDescription)
            self.warningAlert("데이터 불러오기 실패") { () -> Void in
                self.navigationController?.popViewController(animated: true)
            }
        }
        return ddaylist
    }
    
    // 새 D-Day 객체를 저장하는 메소드
    func insert(_ data: DDayData) {
        // 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "DDay", into: self.coreDataStack.mainQueueContext) as! DDayMO
        
        // DDayData로부터 값을 복사한다.
        object.order = data.order!
        object.identifier = data.identifier
        object.ddayDate = data.ddayDate
        object.ddayTitle = data.ddayTitle
        object.notificationTime = data.notificationTime
        object.imageExistance = data.imageExistance!
        
        // Log 관리 객체 생성 및 어트리뷰트에 값 대입
        let logObject = NSEntityDescription.insertNewObject(forEntityName: "Log", into: self.coreDataStack.mainQueueContext) as! LogMO
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        logObject.regdate = formatter.string(from: Date())
        logObject.type = LogType.create.rawValue
        
        // 게시글 객체의 logs 속성에 새로 생성된 로그 객체 추가
        object.addToLogs(logObject)
        
        // 영구 저장소에 변경 사항을 반영한다.
        do {
            try self.coreDataStack.saveChanges()
        } catch let e as NSError {
            self.coreDataStack.rollbackChanges()
            NSLog("An error has occurred : %s", e.localizedDescription)
            self.warningAlert("데이터 저장 실패") { () -> Void in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // D-Day 객체를 수정하는 메소드
    func edit(objectID: NSManagedObjectID, order: Int16, identifier: String, ddayDate: Date, ddayTitle: String?, notificationTime: Date?, imageExistance: Bool, onMoveRow: Bool) -> Bool {
        
        let object = self.coreDataStack.mainQueueContext.object(with: objectID)
        
        object.setValue(order, forKey: "order")
        object.setValue(ddayDate, forKey: "ddayDate")
        object.setValue(ddayTitle, forKey: "ddayTitle")
        object.setValue(notificationTime, forKey: "notificationTime")
        object.setValue(identifier, forKey: "identifier")
        object.setValue(imageExistance, forKey: "imageExistance")
        
        
        if onMoveRow == false {
            // Log 관리 객체 생성 및 어트리뷰트에 값 대입
            let logObject = NSEntityDescription.insertNewObject(forEntityName: "Log", into: self.coreDataStack.mainQueueContext) as! LogMO
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
            logObject.regdate = formatter.string(from: Date())
            logObject.type = LogType.edit.rawValue
            
            // 게시글 객체의 logs 속성에 새로 생성된 로그 객체 추가
            (object as! DDayMO).addToLogs(logObject)
        }
        
        do {
            try self.coreDataStack.saveChanges()
            return true
        } catch {
            self.coreDataStack.rollbackChanges()
            return false
        }
    }
    
    // D-Day 객체를 삭제하기 위한 메소드
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        // 삭제할 객체를 찾아, 컨텍스트에서 삭제한다.
        let object = self.coreDataStack.mainQueueContext.object(with: objectID)
        self.coreDataStack.mainQueueContext.delete(object)
        
        do {
            // 삭제된 내역을 영구저장소에 반영한다.
            try self.coreDataStack.saveChanges()
            return true
        } catch let e as NSError {
            self.coreDataStack.rollbackChanges()
            NSLog("An error has occurred : %s", e.localizedDescription)
            return false
        }
    }
}
