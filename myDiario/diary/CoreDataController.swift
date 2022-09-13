 //
//  CoreDataController.swift
//  
//
//  Created by Enrico Alberti on 02/12/17.
//

import Foundation
import CoreData
import UIKit

 class CoreDataController{
    //controllo e gestione di tutti i dati salvati dall'utente
    
    static let shared = CoreDataController()
    private var context: NSManagedObjectContext
    
    private init() {
        //recupero l'istanza dell'app delegate della proprietà shared
        
        let application = UIApplication.shared.delegate as! AppDelegate
        
        self.context = application.persistentContainer.viewContext
    }
 }
 
 //MARK: Impegno
 extension CoreDataController{
    
    private func loadImpegniFromFetchRequest(request: NSFetchRequest<Impegno>) -> [Impegno] {
        
        var array = [Impegno]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        
        return array
        
    }
    
    func newImpegno(materia: String, completato: Bool, tipo: String, descrizione: String, perData: String, id : String, colore: String){
        
        //salvo elementi con CoreData nel database.
        
        let entity = NSEntityDescription.entity(forEntityName: "Impegno", in: self.context)
        
        let newImpegnoInFunc = Impegno(entity: entity!, insertInto: self.context)
        
        newImpegnoInFunc.materia = materia
        newImpegnoInFunc.tipo = tipo
        newImpegnoInFunc.completato = completato
        newImpegnoInFunc.descrizione = descrizione
        newImpegnoInFunc.perData = perData
        newImpegnoInFunc.id = id
        newImpegnoInFunc.colore = colore
        
        do {
            
            try self.context.save()
            
        } catch let error{
            
            print("[CDC] Problema salvataggio Impegno: \(newImpegnoInFunc.id!) in memoria")
            print("  Stampo l'errore: \n \(error) \n")
        }
        print("impegno correttamente salvato")
    }
    
    func completaImpegno(id : String, completato : Bool){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.completato = completato
        do {
            try impegno.managedObjectContext!.save()
        } catch {
            print("[CDC] Errore salvataggio impegno modificato")
        }
    }
    
    func caricaTuttiGliImpegni() -> [Impegno]{
        
        print("[CDC] Recupero tutti gli impegni dal context ")
        
        let request: NSFetchRequest<Impegno> = NSFetchRequest(entityName: "Impegno")
        
        request.returnsObjectsAsFaults = false
        
        let impegni = self.loadImpegniFromFetchRequest(request: request)
        
        return impegni
        
    }
    /*
    private func ImpegniPerData(date: String) {
        
        print("[CDC] Recupero tutti gli impegni dal context ")
        
        let request: NSFetchRequest<Impegno> = NSFetchRequest(entityName: "Impegno")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "perData = %@", date)
        
        request.predicate = predicate
        
        let impegni = self.loadImpegniFromFetchRequest(request: request)
    }
  */
    func ImpegniPerId(Id: String) -> Impegno {
        
        print("[CDC] Recupero tutti gli impegni per id dal context ")
        
        let request: NSFetchRequest<Impegno> = NSFetchRequest(entityName: "Impegno")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "id = %@", Id)
        
        request.predicate = predicate
        
        let impegni = self.loadImpegniFromFetchRequest(request: request)
        
        return impegni[0]
        
    }
    
    ///cancella un impegno in base all'id
    func cancellaImpegno(id: String) {
        
        let impegno = self.ImpegniPerId(Id: id)
        
        self.context.delete(impegno)
        
        do {
            
            try self.context.save()
            
        } catch let errore {
            
            print("[CDC] Problema eliminazione libro ")
            
            print("  Stampo l'errore: \n \(errore) \n")
            
        }
        
    }
 }
 
 //MARK: -Bullet
 extension CoreDataController{
    private func loadBulletFromFetchRequest(request: NSFetchRequest<BulletList>) -> [BulletList] {
           
           var array = [BulletList]()
           
           do {
               
               array = try self.context.fetch(request)
               
               guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
               
           } catch let error {
               
               print("[CDC] Problema esecuzione FetchRequest")
               
               print("  Stampo l'errore: \n \(error) \n")
               
           }
           
           return array
           
       }
       
    func newBullet(date: String, idOfBullet: UUID, actDat: [String], doneList: [Bool]){
           
           //salvo elementi con CoreData nel database.
           
           let entity = NSEntityDescription.entity(forEntityName: "BulletList", in: self.context)
           
           let newBulletInFunc = BulletList(entity: entity!, insertInto: self.context)
           
        newBulletInFunc.date = date
        newBulletInFunc.idOfBullet = idOfBullet
        newBulletInFunc.actualContent = actDat as NSObject
        newBulletInFunc.doneList = doneList as NSObject
           do {
               
               try self.context.save()
               
           } catch let error{
               
            print("[CDC] Problema salvataggio BulletList: \(newBulletInFunc.idOfBullet) in memoria")
               print("  Stampo l'errore: \n \(error) \n")
           }
           print("impegno correttamente salvato")
       }
    
    func caricaTuttiIBullet() -> [BulletList]{
        
        print("[CDC] Recupero tutti i bullet dal context ")
        
        let request: NSFetchRequest<BulletList> = NSFetchRequest(entityName: "BulletList")
        
        request.returnsObjectsAsFaults = false
        
        let bullets = self.loadBulletFromFetchRequest(request: request)
        
        return bullets
        
    }
    func cancellaTuttiIBullet() {
           
           let vals = self.caricaTuttiIBullet()
           
           for vg in vals{
               self.context.delete(vg)
           }
           
           do {
               
               try self.context.save()
               
           } catch let errore {
               
               print("[CDC] Problema eliminazione  ")
               
               print("  Stampo l'errore: \n \(errore) \n")
               
           }
           
       }
    func BulletsPerData(data: String) -> [BulletList]{
        
        print("[CDC] Recupero tutti i bullet per data dal context ")
        
        let request: NSFetchRequest<BulletList> = NSFetchRequest(entityName: "BulletList")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "date = %@", data)
        
        request.predicate = predicate
        
        let bullets = self.loadBulletFromFetchRequest(request: request)
        
        return bullets
        
    }
 }
 
 //MARK: -Orario
 extension CoreDataController{
    func newOrario(materia: String, descrizione: String, from: String, to: String, giorno: String, colore : String, id : String){
        
        //salvo elementi con CoreData nel database.
        
        let entity = NSEntityDescription.entity(forEntityName: "OrarioD", in: self.context)
        
        let newOrarioInFunc = OrarioD(entity: entity!, insertInto: self.context)
        
        
        newOrarioInFunc.materia = materia
        newOrarioInFunc.from = from
        newOrarioInFunc.to = to
        newOrarioInFunc.descrizione = descrizione
        newOrarioInFunc.giorno = giorno
        newOrarioInFunc.colore = colore
        newOrarioInFunc.id = id
        
        do {
            try self.context.save()
        } catch let error{
            print("[CDC] Problema salvataggio orario: \( newOrarioInFunc.materia) in memoria")
            print("  Stampo l'errore: \n \(error) \n")
      }
    }
    
    func loadOrarioFromFetchRequest(request: NSFetchRequest<OrarioD>) -> [OrarioD] {
        
        var array = [OrarioD]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        
        return array
        
    }
    
    func caricaTuttiGliOrari() -> [OrarioD]{
        
        print("[CDC] Recupero tutti orari")
        
        let request: NSFetchRequest<OrarioD> = NSFetchRequest(entityName: "OrarioD")
        
        request.returnsObjectsAsFaults = false
        
        var array = [OrarioD]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        //let impegni = self.loadValutazFromFetchRequest(request: request)
        
        return array
        
    }
    
    func OrarPerGiorno(gio: String) -> [OrarioD] {
        
        print("[CDC] Recupero tutti gli orari dal context ")
        
        let request: NSFetchRequest<OrarioD> = NSFetchRequest(entityName: "OrarioD")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "giorno = %@", gio)
        
        request.predicate = predicate
        
        let regt = self.loadOrarioFromFetchRequest(request: request)
        
        return regt
        
    }
    
    func cancellaOrario(id: String) {
        
        let request: NSFetchRequest<OrarioD> = NSFetchRequest(entityName: "OrarioD")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "id = %@", id)
        
        request.predicate = predicate
        
        let regt = self.loadOrarioFromFetchRequest(request: request)
        
        for vg in regt{
            self.context.delete(vg)
        }
        
        do {
            
            try self.context.save()
            
        } catch let errore {
            
            print("[CDC] Problema eliminazione  ")
            
            print("  Stampo l'errore: \n \(errore) \n")
            
        }
        
    }
    
    func cancellaTuttiGliOrari() {
        
        let vals = self.caricaTuttiGliOrari()
        
        for vg in vals{
            self.context.delete(vg)
        }
        
        do {
            
            try self.context.save()
            
        } catch let errore {
            
            print("[CDC] Problema eliminazione  ")
            
            print("  Stampo l'errore: \n \(errore) \n")
            
        }
        
    }
    
    func OrariPerId(Id: String) -> OrarioD {
        
        print("[CDC] Recupero tutti orari per id dal context ")
        
        let request: NSFetchRequest<OrarioD> = NSFetchRequest(entityName: "OrarioD")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "id = %@", Id)
        
        request.predicate = predicate
        
        let impegni = self.loadOrarioFromFetchRequest(request: request)
        
        return impegni[0]
        
    }
    
 }

 //MARK: -Immagini
 
 extension CoreDataController{
    
    func newImage(forImpegnoId: String, forMateria: String, ImageString: String, ImageID: String, data: String, descrizione: String){
        let entity = NSEntityDescription.entity(forEntityName: "Immagini", in: self.context)
        
        let newImmagineInFunc = Immagini(entity: entity!, insertInto: self.context)
        newImmagineInFunc.data = data
        newImmagineInFunc.idOfImage = ImageID
        newImmagineInFunc.idOfImpegno = forImpegnoId
        newImmagineInFunc.image = ImageString
        newImmagineInFunc.materia = forMateria
        newImmagineInFunc.descrizione = descrizione
        
        do {
            
            try self.context.save()
            
        } catch let error{
            
            print("[CDC] Problema salvataggio Impegno: \(String(describing: newImmagineInFunc.idOfImage)) in memoria")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
    }
    
    func ImmaginiPerMateria(materia: String)-> [Immagini] {
        
        print("[CDC] Recupero tutte le immagini dal context ")
        
        let request: NSFetchRequest<Immagini> = NSFetchRequest(entityName: "Immagini")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "materia = %@", materia)
        
        request.predicate = predicate
        
        let immagini = self.loadImmaginiFromFetchRequest(request: request)
        
        return immagini
        
    }
    
    
    func loadImmaginiFromFetchRequest(request: NSFetchRequest<Immagini>) -> [Immagini] {
        
        var array = [Immagini]()
        
        do {
            
            array = try self.context.fetch(request)
            
            guard array.count > 0 else {print("[CDC] Non ci sono elementi da leggere "); return []}
            
        } catch let error {
            
            print("[CDC] Problema esecuzione FetchRequest")
            
            print("  Stampo l'errore: \n \(error) \n")
            
        }
        
        return array
        
    }
    
    func ImmaginiPerId(Id: String) -> Immagini {
        
        print("[CDC] Recupero tutti le img per id dal context ")
        
        let request: NSFetchRequest<Immagini> = NSFetchRequest(entityName: "Immagini")
        
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "idOfImage = %@", Id)
        
        request.predicate = predicate
        
        let impegni = self.loadImmaginiFromFetchRequest(request: request)
        
        return impegni[0]
        
    }
    
    
    func cancellaImmagine(id: String) {
        
        let immag = self.ImmaginiPerId(Id: id)
        
        self.context.delete(immag)
        
        do {
            
            try self.context.save()
            
        } catch let errore {
            
            print("[CDC] Problema eliminazione libro ")
            
            print("  Stampo l'errore: \n \(errore) \n")
            
        }
        
    }
 }
