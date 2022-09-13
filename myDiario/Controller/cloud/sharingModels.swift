//
//  sharingModels.swift
//  myDiario
//
//  Created by Enrico on 14/03/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreLocation

/*class sharedImpegno {
    
    static let recordType = "sharedImpegno"
    private let id: CKRecord.ID
    let name: String
    let infos: String
    let database: CKDatabase
    private(set) var utenti: [user]? = nil
    //retrieve when called
    init?(record: CKRecord, database: CKDatabase) {
        let name = record["name"] as? String
        let infos = record["infos"] as? String
        id = record.recordID
        self.name = name ?? "[not available]"
        self.infos = infos ?? "[not available]"
        self.database = database
        if let userRecords = record["utenti"] as? [CKRecord.Reference] {
          user.fetchNotes(for: userRecords) { utenti in
            self.utenti = utenti
            print(utenti)
          }
        }
      }
    }
    

class user{
    private let id: CKRecord.ID
    private(set) var userLabel: String?
    let sharedImpegnoReference: CKRecord.Reference?

    init(record: CKRecord) {
      id = record.recordID
      userLabel = record["name"] as? String
      sharedImpegnoReference = record["impegno"] as? CKRecord.Reference
    }
    
    static func fetchNotes(_ completion: @escaping (Result<[user], Error>) -> Void) {
      let query = CKQuery(recordType: "user",
                          predicate: NSPredicate(value: true))
      let container = CKContainer.default()
      
      container.publicCloudDatabase.perform(query, inZoneWith: nil) { results, error in
        if let error = error {
          DispatchQueue.main.async {
            completion(.failure(error))
          }
          return
        }
        guard let results = results else {
          DispatchQueue.main.async {
            print(error)
          }
          return
        }
        let users = results.map(user.init)
        DispatchQueue.main.async {
          completion(.success(users))
        }
      }
    }
    
    static func fetchNotes(for references: [CKRecord.Reference], _ completion: @escaping ([user]) -> Void) {
      let recordIDs = references.map { $0.recordID }
      let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
      operation.qualityOfService = .utility
      
      operation.fetchRecordsCompletionBlock = { records, error in
        let users = records?.values.map(user.init) ?? []
        DispatchQueue.main.async {
          completion(users)
        }
      }
      
      Model.currentModel.privateDB.add(operation)
    }
}*/
