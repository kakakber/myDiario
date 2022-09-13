//
//  typesModels.swift
//  myDiario
//
//  Created by Enrico on 14/03/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import Foundation
import CloudKit

class sharedImpegno: NSObject{
    var id: CKRecord.ID!
    var infos: String!
    var name: String!
    
}

class Model{
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    let sharedDB: CKDatabase
    
    static var currentModel = Model()
    
    var sharedImpegni = [sharedImpegno]()
    
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        sharedDB = container.sharedCloudDatabase
    }
    
    func refreshData(completion: @escaping ([sharedImpegno], Error?)->()){
        print("getting sum data!")
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "createdAt", ascending: false)
        let query = CKQuery(recordType: "sharedImpegno", predicate: pred)
        //query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["infos", "name"]
        operation.resultsLimit = 50
        let zone = CKRecordZone(zoneName: "sharedImpegniZone")
        operation.zoneID = zone.zoneID
        
        var newshImpegni = [sharedImpegno]()
        
        operation.recordFetchedBlock = { record in
            let impegno = sharedImpegno()
            impegno.id = record.recordID
            impegno.infos = record["infos"]
            impegno.name = record["name"]
            newshImpegni.append(impegno)
            operation.queryCompletionBlock = {[unowned self] (cursor, error) in
                DispatchQueue.main.async {
                    if error == nil{
                        print("all good")
                        self.sharedImpegni = newshImpegni
                        completion(self.sharedImpegni, nil)
                    }else{
                        completion([], error)
                        print("error")
                    }
                }
            }
        }
        privateDB.add(operation)
        print("protocol over")
    }
    
    func writeSomeData(completion: @escaping(Error?)->()){
        let recZone: CKRecordZone = CKRecordZone(zoneName: "sharedImpegniZone")
        let sumRecord = CKRecord(recordType: "sharedImpegno", zoneID: recZone.zoneID)
        sumRecord["name"] = "NomePrivate1Zone" as CKRecordValue
        sumRecord["infos"] = "InfoPrivate1Zone" as CKRecordValue
        /*self.publicDB.save(sumRecord) { (record, error) in
            if let error = error{
                print("error in getting data")
                completion(error)
            }else{
                print("successful")
                completion(nil)
            }
        }*/
        self.privateDB.save(sumRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error{
                    print("error in getting data")
                    completion(error)
                }else{
                    print("saved successfully")
                    completion(nil)
                }
            }
        }
    }
    
     func createSharedZone(completion:@escaping (CKRecordZone?, Error?)->Void) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let customZone = CKRecordZone(zoneName: "sharedImpegniZone")
        
        privateDatabase.save(customZone, completionHandler: ({returnRecord, error in
            completion(returnRecord, error)
        }))
    }
}
