//
//  Var e func.swift
//  AppStudente
//
//  Created by Enrico Alberti on 04/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import Foundation
import UIKit

var materiaV : String = ""
var tipoV : String = ""
var descrizioneV : String = ""
var dataV : String = ""
var idV : String = ""

var selectedImage = UIImage()
var selectedDateInCalendar = Date()


func formatDate(format: String, date: Date)->String{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "it_IT")
    dateFormatter.dateFormat = format
    let strDate = dateFormatter.string(from: date)
    
    return strDate
}

func dateFromString(format: String, date: String)->Date{
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "it_IT")
    dateFormatter.dateFormat = format
    let strDate = dateFormatter.date(from: date)
    
    return strDate!
}

func getDateOutput(date: Date, format: String)-> String{
    let calendarz = Calendar.current
    if calendarz.isDateInTomorrow(date){
        return "Domani"
    }
    if calendarz.isDateInToday(date){
        return "Oggi"
    }
    return formatDate(format: format, date: date)
}

//sorter

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}

func sortImpArrayByDate(imp : [Impegno], withLimit: Bool, limitingFrom: Date)->[Impegno]{
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE dd MMMM yyyy"
    formatter.locale = Locale(identifier: "it_IT")
    
    //filtro impegni per data
    let tuttiImp = imp.sorted { (impegnoA, impegnoB) -> Bool in
        if impegnoB.perData != nil{
            if impegnoA.perData != nil{
                 return formatter.date(from: impegnoA.perData!)! < formatter.date(from: impegnoB.perData!)!
            }else{
                 impegnoA.id = "ses"
                 CoreDataController.shared.cancellaImpegno(id: "ses")
                 return false
            }
        }else{
            impegnoB.id = "sus"
            CoreDataController.shared.cancellaImpegno(id: "sus")
            return false
        }
    }
    if withLimit{
        var limited = [Impegno]()
        //tolgo gli impegni inferiori a certa data
        for t in tuttiImp{
            if formatter.date(from: t.perData!)! > limitingFrom{
                limited.append(t)
            }
        }
        return limited
    }else{
        return tuttiImp
    }
}


class EventoDiario{
    var tipo = String()
    var data = String()
    var descrizione = String()
    var materia = String()
    var id = String()
    
    init(id: String, tipo: String, data: String, descrizione: String, materia: String) {//inizializzazione
        self.id = id
        self.tipo = tipo
        self.data = data
        self.descrizione = descrizione
        self.materia = materia
    }
    
    
    init() {}
    
    //funzioni di aggiornamento
    
    func update(type : tipiDiAggiornamentoEventoDiario, id: String, testoDiUpdate: String){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        switch type {
        case .tipo:
            impegno.tipo = testoDiUpdate;
        case .data:
            impegno.perData = testoDiUpdate;
        case .descrizione:
            impegno.descrizione = testoDiUpdate;
        default:
            print("eventoDiario.Update fail in switch")
            return
        }
        //aggiorno
        do{
            try impegno.managedObjectContext!.save()
        } catch{
            print("errore nella modifica dell'impegno di tipo '\(type)'");
        }
    }
    func update(){//update tutto
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.tipo = self.tipo
        impegno.perData = self.data
        impegno.descrizione = self.descrizione
        impegno.materia = self.materia
        
        do{
            try impegno.managedObjectContext!.save()
        } catch{
            print("errore nella modifica dell'impegno \(error.localizedDescription)")
        }
    }
}

enum tipiDiAggiornamentoEventoDiario{
    case tipo
    case data
    case descrizione
}

//cells models
class bubblyModel{
    let materia: String
    let tipo: String
    let descrizione: String
    let data: String
    let done: Bool
    
    init(_ impegno: Impegno) {
        materia = impegno.materia!.uppercased()
        tipo = impegno.tipo!.uppercased()
        descrizione = impegno.descrizione!
        data = "Per \(impegno.perData!)"
        done = impegno.completato
    }
}



class skeletonModel{//modello per riempire cells
    var descrizione: String
    let tipo: String
    let materia: String
    let data: String
    
    init(_ impegno: Impegno) {
        descrizione = impegno.descrizione!
        tipo = impegno.tipo!.uppercased()
        materia = impegno.materia!.uppercased()
        data = "Per \(getDateOutput(date: dateFromString(format: "EEEE dd MMMM yyyy", date: impegno.perData!), format: "EEEE dd MMMM "))"
        if impegno.descrizione!.isEmpty{
            descrizione = "Nessuna descrizione"
        }
    }
}



//MARK: - extentions

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

extension Date {
    public func setTime(hour: Int, min: Int, sec: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec
        
        return cal.date(from: components)
    }
}

extension Date {
    
    var dayBefore: Date {
        let oneDay:Double = 60 * 60 * 24
        return self.addingTimeInterval(-(Double(oneDay)))
    }
    var dayAfter: Date {
        let oneDay:Double = 60 * 60 * 24
        return self.addingTimeInterval((Double(oneDay)))
    }
    var monthAfter: Date {
        let oneDay:Double = 60 * 60 * 24 * 30
        return self.addingTimeInterval((Double(oneDay)))
    }
}

extension Date {
    //estensione per differenze di tempo
    func offsetFrom(date: Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m" + " " + seconds
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        if let second = difference.second, second > 0 { return seconds }
        return ""
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
