//
//  tryChat.swift
//  myDiario
//
//  Created by Enrico on 13/03/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit
import CloudKit

class tryChat: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //writeSomeData()
        CKContainer.default().requestApplicationPermission(CKContainer_Application_Permissions.userDiscoverability) { (status, error) in
            switch status {
            case .granted:
                print("granted")
            case .denied:
                print("denied")
            case .initialState:
                print("initial state")
            case .couldNotComplete:
                print("an error as occurred: ", error ?? "Unknown error")
            @unknown default:
                fatalError()
            }
        }
        /*Model.currentModel.writeSomeData { (error) in
            if error != nil{
                print("error")
            }
        }*/
        getData()
        /*Model.currentModel.createSharedZone { (zone, error) in
            if error != nil{
                print("error")
            }
        }*/
    }
    
    var sharedImpegni = [sharedImpegno]()
    
    func getData(){
        Model.currentModel.refreshData { (listaImp, error) in
            if error != nil{
                print("error")
            }else{
                for x in listaImp{
                    print(x.name!)
                }
            }
        }
    }
    
    @IBAction func getData(_ sender: Any) {
        print("getting")
        /*var model = Model.currentModel
        model.refresh { (error) in
            if error != nil { print(error)}
            if !model.sharedImpegni.isEmpty{
                for x in model.sharedImpegni{
                    print("nome: \(x.name) - \(x.infos) - \(x.utenti)")
                    if !((x.utenti?.isEmpty ?? true)){
                        for t in x.utenti!{
                            print("utente: '\(t) for \(x.name)")
                        }
                    }
                }
            }
        }
        
    }*/
    }
    @IBAction func saveBullet(_ sender: Any) {
        var dat = formatDate(format: "yyyy-MM-dd HH:mm", date: Date())
        //CoreDataController.shared.newBullet(date: dat, idOfBullet: UUID(), content: "prima bullet list!!!!!")
        var f = CoreDataController.shared.caricaTuttiIBullet()
        for x in f{
            print("\(x.idOfBullet!)")
        }
    }
}
