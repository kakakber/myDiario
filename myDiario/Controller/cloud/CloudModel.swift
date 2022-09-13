//
//  CloudModel.swift
//  myDiario
//
//  Created by Enrico on 14/03/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import Foundation
import CloudKit

/*
class Model {
  // MARK: - iCloud Info
  let container: CKContainer
  let publicDB: CKDatabase
  let privateDB: CKDatabase
  
  // MARK: - Properties
  private(set) var sharedImpegni: [sharedImpegno] = []
  static var currentModel = Model()
  
  init() {
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  @objc func refresh(_ completion: @escaping (Error?) -> Void){
    print("refreshing")
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "sharedImpegno", predicate: predicate)
    sharedImpegni(forQuery: query, completion)
  }
  
  private func sharedImpegni(forQuery query: CKQuery, _ completion: @escaping (Error?) -> Void) {
       publicDB.perform(query,
         inZoneWith: CKRecordZone.default().zoneID) { [weak self] results, error in
       guard let self = self else { return }
       if let error = error {
         DispatchQueue.main.async {
           completion(error)
         }
         return
       }
       guard let results = results else { return }
        //print(results)
       self.sharedImpegni = results.compactMap {
        return sharedImpegno(record: $0, database: self.publicDB)
       }
       DispatchQueue.main.async {
         completion(nil)
       }
     }
  }
}*/
