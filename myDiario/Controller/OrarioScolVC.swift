//
//  OrarioScolVC.swift
//  myDiario
//
//  Created by Enrico on 13/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit
import ChameleonFramework
import Canvas
import DZNEmptyDataSet

class materiaCellfOr : UITableViewCell{
  
    @IBOutlet weak var segmentoVert: UIView!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var descrizione: UILabel!
    
    @IBOutlet weak var ipadSelectView: UIView!
    
}

class miniCollCell : UICollectionViewCell{
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        view.layer.cornerRadius = view.frame.size.width/2
        view.clipsToBounds = true
    }
}

class OrarioScolVC: UIViewController, UITextFieldDelegate{
   
    
    var idfg = ""
    var isMod = false
    
    var initialHour = Date()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segv: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.tabBar.isHidden = true
        collViewMini.delegate = self
        collViewMini.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        let itms = ["lun", "mar", "mer", "gio", "ven", "sab"]
        
        // Do any additional setup after loading the view.
        
        addToolBar(textField: materia)
        addToolBar(textField: descrizione)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let myComponents = Calendar.current.component(.weekday, from: initialHour)
        print(initialHour)
        print("day \(myComponents)")
        segment.selectedSegmentIndex = formatterDate(initialHour)
        daySegment(self)
        //CoreDataController.shared.cancellaOrarTut()
        newOra.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        print(lastHour())
    }
    var isFrom = false
    
    func formatterDate(_ dat: Date) -> Int{
        let myComponents = Calendar.current.component(.weekday, from: dat)
        switch myComponents {
        case 2,3,4,5,6,7:
            print("giorno: \(myComponents-2)")
            return myComponents-2
        default:
            print("domenica")
            return 0
        }
    }
    
    var orariPerGiorno : [OrarioD] = []
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func daySegment(_ sender: Any) {
        switch segment.selectedSegmentIndex {
        case 0:
            giorno = "lunedì"
        case 1:
            giorno = "martedì"
        case 2:
            giorno = "mercoledì"
        case 3:
            giorno = "giovedì"
        case 4:
            giorno = "venerdì"
        case 5:
            giorno = "sabato"
        default:
            giorno = "lunedì"
        }
        print("inseg")
        orariPerGiorno = CoreDataController.shared.OrarPerGiorno(gio: giorno)
        if #available(iOS 13.0, *) {
            segv.backgroundColor = UIColor.secondarySystemBackground
        } else {
            // Fallback on earlier versions
            segv.backgroundColor = UIColor.white
        }
        tableView.reloadData()
    }
    var giorno = ""
    @IBOutlet weak var collViewMini: UICollectionView!
    
    @IBOutlet weak var fromOra: UILabel!
    @IBOutlet weak var toOra: UILabel!
    
    @IBOutlet weak var materia: UITextField!
    @IBOutlet weak var descrizione: UITextField!
    
    @IBOutlet weak var selectOra: UIView!
    @IBOutlet weak var segmentio: UIView!
    
    @IBOutlet weak var newOra: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @objc func donePressed(){
        materia.resignFirstResponder()
        descrizione.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        materia.resignFirstResponder()
        descrizione.resignFirstResponder()
    }
    
    @IBOutlet weak var newMRD: UIView!
    @IBOutlet weak var plusd: UIBarButtonItem!
    
    
    func lastHour()->String{
        if !orariPerGiorno.isEmpty{
            return  orariPerGiorno[orariPerGiorno.count-1].to!
        }
        return "08:00"
    }
    
    var clre = "arancio"
    
    @IBOutlet weak var aggiungiOut: UIButton!
    var indxx = 0;//per tableview
    
    let colori : [UIColor] = [UIColor.flatBlue(), FlatRed(), FlatYellow(), FlatOrange(), FlatPurple(), FlatPlum(), FlatPink(), FlatGray(), FlatGreen(), FlatMint(), FlatCoffee()]
}


//MARK: - addingOrario
extension OrarioScolVC{
    
    @IBAction func plusAct(_ sender: Any) {
        aggiungiOut.titleLabel?.text! = "Aggiungi"
        materia.text! = ""
        datePicker.date = dateFromString(format: "HH:mm", date: lastHour())
        fromOra.text! = lastHour()
        toOra.text! = lastHour()
        descrizione.text! = ""
        if newOra.isHidden{
            newMRD.startCanvasAnimation()
            newMRD.isHidden = false
            newOra.isHidden = false
        }else{
            newMRD.isHidden = true
            newOra.isHidden = true
        }
    }
    @IBAction func aggiungi(_ sender: Any) {
        newMRD.isHidden = true
        newOra.isHidden = true
        if isMod {
            isMod = false
            let or = CoreDataController.shared.OrariPerId(Id: idfg)
            or.materia! = materia.text!
            or.descrizione! = descrizione.text!
            or.colore! = clre
            or.from! = fromOra.text!
            or.to! = toOra.text!
            or.giorno! = giorno
            do{
                try or.managedObjectContext!.save()
            } catch{
                print("errore nella modifica dell'orario")
            }
        }else{
            CoreDataController.shared.newOrario(materia: materia.text!, descrizione: descrizione.text!, from: fromOra.text!, to: toOra.text!, giorno: giorno, colore: clre, id:  UUID().uuidString)
        }
        orariPerGiorno = CoreDataController.shared.OrarPerGiorno(gio: giorno)
        isMod = false
        tableView.reloadData()
    }
    @IBAction func annulla(_ sender: Any) {
        //CoreDataController.shared.cancellaOrar()
        newMRD.isHidden = true
        newOra.isHidden = true
        materia.resignFirstResponder()
        descrizione.resignFirstResponder()
        selectOra.isHidden = true
    }
    
    @IBAction func orariofromPick(_ sender: Any) {
        isFrom = true
        if selectOra.isHidden{
            materia.resignFirstResponder()
            descrizione.resignFirstResponder()
            datePicker.isHidden = false
            selectOra.isHidden = false
        }else{
            datePicker.isHidden = true
            selectOra.isHidden = true
        }
    }
    @IBAction func orariotoPick(_ sender: Any) {
        isFrom = false
        if selectOra.isHidden{
            materia.resignFirstResponder()
            descrizione.resignFirstResponder()
            datePicker.isHidden = false
            selectOra.isHidden = false
        }else{
            datePicker.isHidden = true
            selectOra.isHidden = true
        }
    }
    @IBAction func ok(_ sender: Any) {
        selectOra.isHidden = true
    }
    
    @IBAction func backV(_ sender: Any) {
        isMod = false
        newMRD.isHidden = true
        newOra.isHidden = true
        materia.resignFirstResponder()
        descrizione.resignFirstResponder()
        selectOra.isHidden = true
    }
    
    func colorFromString(str: String) -> UIColor{
        var ou = FlatCoffee()
        switch str {
        case "blu":
            ou = FlatBlue()
        case "rosso":
            ou = FlatRed()
        case "giallo":
            ou = FlatYellow()
        case "arancio":
            ou = FlatOrange()
        case "viola":
            ou = FlatPurple()
        case "plum":
            ou = FlatPlum()
        case "rosa":
            ou = FlatPink()
        case "grigio":
            ou = FlatGray()
        case "verde":
            ou = FlatGreen()
        case "menta":
            ou = FlatMint()
        case "caffe":
            ou = FlatCoffee()
        default:
            ou = FlatCoffee()
        }
        
        return ou
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: sender.date)
        if let day = components.hour, let min = components.minute{
            if isFrom{
                if min < 10{
                    fromOra.text! = "\(day):0\(min)"
                    if day < 10{
                        fromOra.text! = "0\(day):0\(min)"
                    }
                }else{
                    fromOra.text! = "\(day):\(min)"
                    if day < 10{
                        fromOra.text! = "0\(day):\(min)"
                    }
                }
            }else{
                if min < 10{
                    toOra.text! = "\(day):0\(min)"
                    if day < 10{
                        toOra.text! = "0\(day):0\(min)"
                    }
                }else{
                    toOra.text! = "\(day):\(min)"
                    if day < 10{
                        toOra.text! = "0\(day):\(min)"
                    }
                }
            }
        }
    }
    
    func frmtDT(){
        
    }
}

//MARK: - editing cells
extension OrarioScolVC{
    
    func mod(action: UIAlertAction){
        isMod = true
        aggiungiOut.titleLabel?.text! = "Modifica"
        materia.text! = orariPerGiorno[indxx].materia!
        descrizione.text! = orariPerGiorno[indxx].descrizione!
        fromOra.text! = orariPerGiorno[indxx].from!
        toOra.text! = orariPerGiorno[indxx].to!
        segmentio.backgroundColor = colorFromString(str: orariPerGiorno[indxx].colore!)
        clre = orariPerGiorno[indxx].colore!
        
        if newOra.isHidden{
            newMRD.startCanvasAnimation()
            newMRD.isHidden = false
            newOra.isHidden = false
        }
    }
    
    func elim(action: UIAlertAction){
        CoreDataController.shared.cancellaOrario(id: idfg)
        orariPerGiorno = CoreDataController.shared.OrarPerGiorno(gio: giorno)
        if #available(iOS 13.0, *) {
            segv.backgroundColor = UIColor.secondarySystemBackground
        } else {
            // Fallback on earlier versions
            segv.backgroundColor = UIColor.white
        }
        tableView.reloadData()
    }
       
}

//MARK: - collectionView
extension OrarioScolVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return colori.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "lkj", for: indexPath) as! miniCollCell
           
           cell.view.backgroundColor = colori[indexPath.row]
           
           return cell
       }
       /*UIColor.flatBlue(), FlatRed(), FlatYellow(), FlatOrange(), FlatPurple(), FlatPlum(), FlatPink(), FlatGray(), FlatGreen(), FlatMint(), FlatCoffee()*/
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           switch indexPath.row {
           case 0:
               clre = "blu"
           case 1:
               clre = "rosso"
           case 2:
               clre = "giallo"
           case 3:
               clre = "arancio"
           case 4:
               clre = "viola"
           case 5:
               clre = "plum"
           case 6:
               clre = "rosa"
           case 7:
               clre = "grigio"
           case 8:
               clre = "verde"
           case 9:
               clre = "menta"
           case 10:
               clre = "caffe"
           default:
               clre = "caffe"
           }
           
           segmentio.backgroundColor = colorFromString(str: clre)
       }
}
//MARK: - tableView
extension OrarioScolVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orariPerGiorno.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction(title: "Modifica", style: .default, handler: self.mod))
        menu.addAction(UIAlertAction(title: "Elimina", style: .destructive, handler: self.elim))
        menu.addAction(UIAlertAction(title: "Indietro", style: .cancel, handler: nil))
        
        if let presenter = menu.popoverPresentationController {
            let ic = tableView.cellForRow(at: indexPath) as! materiaCellfOr
            presenter.sourceView = ic.ipadSelectView
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        indxx = indexPath.row
        idfg = orariPerGiorno[indexPath.row].id!
        self.present(menu, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iuy") as! materiaCellfOr
        
        if indexPath.row == 0{
            segv.backgroundColor = colorFromString(str: orariPerGiorno[indexPath.row].colore!).withAlphaComponent(0.2)
        }
        
        cell.backgroundColor = colorFromString(str: orariPerGiorno[indexPath.row].colore!).withAlphaComponent(0.2)
        cell.descrizione.text! = orariPerGiorno[indexPath.row].descrizione!
        cell.from.text! = orariPerGiorno[indexPath.row].from!
        cell.to.text! = orariPerGiorno[indexPath.row].to!
        cell.materia.text! = orariPerGiorno[indexPath.row].materia!
        cell.segmentoVert.backgroundColor = colorFromString(str: orariPerGiorno[indexPath.row].colore!)
        
        return cell
    }
}

//MARK: - dznEmptyDataSet
extension OrarioScolVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "\nNessuna lezione per questa giornata"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)

    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "noOre")
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Premi il pulsante + per aggiungerne una"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
}


//MARK: - add Toolbar
extension OrarioScolVC{
    func addToolBar(textField: UITextField){
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
}
