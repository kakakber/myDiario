//
//  NewEventoGroupedVC.swift
//  myDiario
//
//  Created by Enrico on 06/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit
import ChameleonFramework


fileprivate var materie : [String] = []
fileprivate var tipi : [String] = []

// MARK: - EventoGroupedVC
class NewEventoGroupedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        descriz = ""
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.keyboardDismissMode = .onDrag
        materie = UserDefaults.standard.stringArray(forKey: "materieKey") ?? []
        tipi = UserDefaults.standard.stringArray(forKey: "tipiKey") ?? []
        eventoData.color = 4
        setUpNotificCenter()
    }
    var tipoOk = false
    var matOk = false
    
    //table view data
    var expanded = false
    var RowSelected = 0
    var SecSelected = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("GettingBackImm"), object: nil)
    }
    
    var isFromCalendar = false
    var eventualDate = Date()
    
    @IBOutlet weak var salvaOut: UIBarButtonItem!
    @IBAction func salvaAct(_ sender: Any) {
        if eventoData.tipo == "" || eventoData.materia == ""{
            return
        }
        eventoData.id = UUID().uuidString
        eventoData.saveData()
        dismiss(animated: true, completion: nil)
    }
    
    //-----------
}
// MARK: - Struct

struct dataToUpload{
    var descrizione: String
    var materia: String
    var tipo: String
    var data: String
    var id: String
    var color: Int
    
    func saveData(){
        CoreDataController.shared.newImpegno(materia: materia, completato: false, tipo: tipo, descrizione: descrizione, perData: data, id: id, colore: "\(color)")
    }
}

var eventoData = dataToUpload(descrizione: "", materia: "", tipo: "", data: "", id: "", color: 4)

//MARK: - NSNotification center
extension NewEventoGroupedVC{
    func setUpNotificCenter(){
        NotificationCenter.default.addObserver(self, selector: #selector(tipChanged(_:)), name: NSNotification.Name(rawValue: "TipoChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(matChanged(_:)), name: NSNotification.Name(rawValue: "MatChanged"), object: nil)
    }
    @objc func tipChanged(_ notification:Notification) {
           // Do something now
           tipoOk = true
           if tipoOk && matOk{
               salvaOut.isEnabled = true
           }
       }
       @objc func matChanged(_ notification:Notification) {
           // Do something now
           matOk = true
           if tipoOk && matOk{
               salvaOut.isEnabled = true
           }
       }
}

// MARK: - Table View
extension NewEventoGroupedVC{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "DETTAGLI"
        case 2:
            return ""
        default:
            return "DESCRIZIONE"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if RowSelected == indexPath.row && SecSelected == indexPath.section && SecSelected > 0{
            if RowSelected == 1 && SecSelected == 2{
                 return expanded == true ? 109.5 : 45
            }
            if RowSelected == 0 && SecSelected == 1{
                return expanded == true ? 170 : 45
            }
            if RowSelected == 1 && SecSelected == 1{
                return expanded == true ? 170 : 45
            }
            return expanded == true ? 180 : 45 //100 per ridotto
        }else if indexPath.section == 0{
            return UITableView.automaticDimension
        }
        return 45
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        if indexPath.row == RowSelected && indexPath.section == SecSelected{
            expanded = expanded == true ? false : true
        }else{
            expanded = true
        }
        
        RowSelected = indexPath.row
        SecSelected = indexPath.section
        
        tableView.beginUpdates()
        tableView.endUpdates()
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let cell = UITableViewCell(style: .default, reuseIdentifier: "infCel")
        cell.textLabel?.text = "hello world!"*/
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! dateCell
            switch indexPath.row{
            case 0:
                cell.title.text = "Materia"
                materie = UserDefaults.standard.stringArray(forKey: "materieKey") ?? []
                print(materie.count)
                if materie.count == 1{
                    cell.data.text = materie[0]
                    matOk = true
                    if tipoOk && matOk{
                        salvaOut.isEnabled = true
                    }
                }else{
                   cell.data.text = ""
                }
                
            case 1:
                cell.title.text = "Tipo"
                tipi = UserDefaults.standard.stringArray(forKey: "tipiKey") ?? []
                if tipi.count == 1{
                    cell.data.text = tipi[0]
                    tipoOk = true
                    if tipoOk && matOk{
                        salvaOut.isEnabled = true
                    }
                }else{
                  cell.data.text = ""
                }
            default:
                let cellDT = tableView.dequeueReusableCell(withIdentifier: "actualDat") as! actualDat
                if isFromCalendar{
                    print(eventualDate)
                    cellDT.data.text = formatDate(format: "EEE dd MMM yy", date: eventualDate)
                    eventoData.data = formatDate(format: "EEEE dd MMMM yyyy", date: eventualDate)
                    cellDT.datePicker.date = eventualDate
                }else{
                    cellDT.data.text! = getDateOutput(date: Date(), format: "EEE dd MMM yy").capitalizingFirstLetter()
                    eventoData.data = formatDate(format: "EEEE dd MMMM yyyy", date: Date())
                }
                return cellDT
            }
            return cell
        case 2:
            switch indexPath.row{
            case 0:
                let cellNotif = tableView.dequeueReusableCell(withIdentifier: "notiCell") as! notiCell
                return cellNotif
            default:
                let cellCol = tableView.dequeueReusableCell(withIdentifier: "colorCell") as! colorCell
                return cellCol
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell") as! descCell
            cell.descrizione.text! = descriz
            //cell.descrizione.placeholder = "Descrizione"
            cell.delegateForH = self
            return cell
        }
    }
}

// MARK: - Delegates extentions
extension NewEventoGroupedVC: newEventCellUpdateDelegate{
    //aggiornamento descCell
    func updateCell() {
        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)
        /* These will causes table cell heights to be recaluclated,
         without reloading the entire cell */
        tableView.beginUpdates()
        tableView.endUpdates()
        // Re-enable animations
        UIView.setAnimationsEnabled(true)
        
        let indexPath = IndexPath(row: 0, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}


//cells declarations
fileprivate var descriz = ""

// MARK: - ActualDat
class actualDat: UITableViewCell{
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        print("awake")
    }
    
    @IBAction func datePick(_ sender: Any) {
        data.text! = getDateOutput(date: datePicker.date, format: "EEE dd MMM yy").capitalizingFirstLetter()
        let fmtDt = formatDate(format: "EEEE dd MMMM yyyy", date: datePicker.date)
        eventoData.data = fmtDt
        let dataToPost:[String: String] = ["data": fmtDt]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DataChanged"), object: nil, userInfo: dataToPost)
    }
    
}
// MARK: - DateCell
class dateCell: UITableViewCell{
    
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var title: UILabel!
    
    var isMat = true
    
    @IBOutlet weak var picker: UIPickerView!
    
    override func awakeFromNib() {
        picker.delegate = self
        picker.dataSource = self
        //picker.selectRow(0, inComponent: 0, animated: true)
        materie = UserDefaults.standard.stringArray(forKey: "materieKey") ?? []
        tipi = UserDefaults.standard.stringArray(forKey: "tipiKey") ?? []
        print("materie: \(materie)")
        print("tipi: \(tipi)")
    }
}

extension dateCell: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        data.text! = isMat == true ? materie[row] : tipi[row]
        if isMat {
            eventoData.materia = materie[row]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MatChanged"), object: nil)
        }else{
            //MARK: - da cambiare
            eventoData.tipo = tipi[row]
            let dataToPost:[String: String] = ["tipo": tipi[row]]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TipoChanged"), object: nil, userInfo: dataToPost)
        }
        print("\(eventoData.materia) - \(eventoData.tipo)")
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch title.text! {
        case "Materia":
            isMat = true
            return materie.count
        default:
            isMat = false
            return tipi.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch title.text! {
        case "Materia":
            return materie[row]
        default:
            return tipi[row]
        }
    }
}


protocol newEventCellUpdateDelegate{
    func updateCell()
}


fileprivate let colori = [FlatNavyBlue(), FlatSkyBlue(), FlatRed(),FlatYellow(), FlatOrange(),FlatPurple(),FlatPlum(), FlatPink(), FlatGray(), FlatGreen(), FlatForestGreen(), FlatMint(), FlatCoffee(), FlatSand()]

// MARK: - ColorCell
class colorCell: UITableViewCell{
    @IBOutlet weak var chosenColor: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        chosenColor.layer.cornerRadius = chosenColor.frame.size.width/2
        chosenColor.clipsToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension colorCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return colori.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColl", for: indexPath) as! cellColl
        row.colView.layer.cornerRadius = row.colView.frame.size.width/2
        row.colView.clipsToBounds = true
        row.colView.layer.backgroundColor = colori[indexPath.row].cgColor
        return row
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chosenColor.layer.backgroundColor = colori[indexPath.row].cgColor
        eventoData.color = indexPath.row
    }
}

class cellColl: UICollectionViewCell{
    
    @IBOutlet weak var colView: UIView!
    
}

// MARK: - NotiCell
class notiCell: UITableViewCell{
    
    @IBOutlet weak var notiSwitch: UISwitch!
    
    @IBOutlet weak var data: UILabel!
}

// MARK: - DescCell

class descCell: UITableViewCell, UITextViewDelegate{
    @IBOutlet weak var descrizione: UITextView!
    var delegateForH : newEventCellUpdateDelegate!
    
    override func awakeFromNib() {
        descrizione.text! = ""
        descrizione.delegate = self
        addToolBar2(textField: descrizione)
    }
    func textViewDidChange(_ textView: UITextView) {
        descriz = descrizione.text!
        let dataToPost:[String: String] = ["desc": descrizione.text!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TextInDescChanged"), object: nil, userInfo: dataToPost)
        eventoData.descrizione = descrizione.text!
        delegateForH.updateCell()
    }
}

extension descCell: UITextFieldDelegate{
    
    func addToolBar2(textField: UITextView){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Fine", style: UIBarButtonItem.Style.done, target: self, action: #selector(donePressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(){
        descrizione.resignFirstResponder()
    }
}
