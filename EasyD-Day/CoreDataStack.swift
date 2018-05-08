//
//  CoreDataStack.swift
//  Photorama
//
//  Created by 박수성 on 2017. 8. 18..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let managedObjectModelName: String
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.managedObjectModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private var applicationDocumentsDirectory: URL = {
        /*
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
        */
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.kr.co.ipdisk.dbspark711")!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url = self.applicationDocumentsDirectory.appendingPathComponent(pathComponent)
        
        let store: NSPersistentStore!
        do {
            store = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("Print adding Persistent Store: \(error)")
        }
        
        return coordinator
    }()
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.name = "Main Queue Context (UI Context)"
        
        return moc
    }()
    
    lazy var privateQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = self.mainQueueContext
        moc.name = "Primary Private Queue Context"
        
        return moc
    }()
    
    required init(modelName: String) {
        managedObjectModelName = modelName
    }
    
    func saveChanges() throws {
        var error: Error?
        
        privateQueueContext.performAndWait {
            if self.privateQueueContext.hasChanges {
                do {
                    try self.privateQueueContext.save()
                } catch let saveError {
                    error = saveError
                }
            }
        }
        
        if let error = error {
            throw error
        }
        
        mainQueueContext.performAndWait {
            if self.mainQueueContext.hasChanges {
                do {
                    try self.mainQueueContext.save()
                } catch let saveError {
                    error = saveError
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    func rollbackChanges() {
        privateQueueContext.performAndWait {
            if self.privateQueueContext.hasChanges {
                self.privateQueueContext.rollback()
            }
        }
        
        mainQueueContext.performAndWait {
            if self.mainQueueContext.hasChanges {
                self.mainQueueContext.rollback()
            }
        }
    }
}
