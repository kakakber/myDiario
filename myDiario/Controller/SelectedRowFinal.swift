//
//  SelectedRowFinal.swift
//  myDiario
//
//  Created by Enrico on 13/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit
import ChameleonFramework

// MARK: - EventoGroupedVC
class SelectedRowFinal: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventoScelto = EventoDiario()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        tableView.keyboardDismissMode = .onDrag
        setUpNotif()
        
        self.navigationItem.title = eventoScelto.materia
    }

    //table view data
    var expanded = false
    var RowSelected = 0
    var SecSelected = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
        eventoScelto.update()
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("GettingBackImm"), object: nil)
    }
    
    var isFromCalendar = false
    var eventualDate = Date()
    
    @IBAction func salvaAct(_ sender: Any) {
        eventoData.id = UUID().uuidString
        eventoData.saveData()
        dismiss(animated: true, completion: nil)
    }
    
    //-----------
}
//MARK: - NSnotificationsCenter
extension SelectedRowFinal{
    func setUpNotif(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeText(_:)), name: NSNotification.Name(rawValue: "TextInDescChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeType(_:)), name: NSNotification.Name(rawValue: "TipoChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeDate(_:)), name: NSNotification.Name(rawValue: "DataChanged"), object: nil)
    }
    @objc func changeText(_ notification: NSNotification){
        if let desc = notification.userInfo?["desc"] as? String{
            eventoScelto.descrizione = desc
            //eventoScelto.update(type: .descrizione, id: eventoScelto.id, testoDiUpdate: desc)
        }
    }
    @objc func changeDate(_ notification: NSNotification){
        if let date = notification.userInfo?["data"] as? String{
            eventoScelto.data = date
            //eventoScelto.update(type: .data, id: eventoScelto.id, testoDiUpdate: date)
        }
    }
    @objc func changeType(_ notification: NSNotification){
        if let tip = notification.userInfo?["tipo"] as? String{
            eventoScelto.tipo = tip
            //eventoScelto.update(type: .tipo, id: eventoScelto.id, testoDiUpdate: tip)
        }
    }
}

// MARK: - Table View
extension SelectedRowFinal{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 1 : 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "DESCRIZIONE"
        default:
            return "TIPO E DATA"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if RowSelected == indexPath.row && SecSelected == indexPath.section && SecSelected > 0{
            if RowSelected == 1{
                return expanded == true ? 250 : 45
            }
            if RowSelected == 0{
                return expanded == true ? 170 : 45
            }
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
            switch indexPath.row {
            case 1:
                let cellDT = tableView.dequeueReusableCell(withIdentifier: "actualDat") as! actualDat
                eventoData.data = eventoScelto.data
                cellDT.datePicker.date = dateFromString(format: "EEEE dd MMMM yyyy", date: eventoScelto.data)
                cellDT.data.text = getDateOutput(date: cellDT.datePicker.date, format: "EEE dd MMM yy").capitalizingFirstLetter()
                return cellDT
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! dateCell
                cell.data.text = eventoScelto.tipo
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descCell") as! descCell
            cell.descrizione.text! = eventoScelto.descrizione
            //cell.descrizione.placeholder = "Descrizione"
            cell.delegateForH = self
            return cell
        }
    }
}

// MARK: - Delegates extentions
extension SelectedRowFinal: newEventCellUpdateDelegate{
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



fileprivate let colori = [FlatNavyBlue(), FlatSkyBlue(), FlatRed(),FlatYellow(), FlatOrange(),FlatPurple(),FlatPlum(), FlatPink(), FlatGray(), FlatGreen(), FlatForestGreen(), FlatMint(), FlatCoffee(), FlatSand()]



