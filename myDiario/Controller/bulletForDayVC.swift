//
//  bulletForDayVC.swift
//  myDiario
//
//  Created by Enrico on 22/03/2020.
//  Copyright © 2020 Enrico Alberti. All rights reserved.
//

import UIKit

fileprivate struct dataModelBullet{
    var stringArray: [String]!
    var boolArray: [Bool]!
}
fileprivate var currentData = dataModelBullet()

class bulletForDayVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var date = Date()
    private var bulletPerToday: BulletList!
    @IBOutlet weak var dataDiOggiTitolo: UILabel!
    
    var ImpegniPerOg = [Impegno]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 36
        print(date)
        //getloaded()
        //CoreDataController.shared.cancellaTuttiIBullet()
        //saveBullet()
        ImpegniPerOg = getImpegForData(date: date)
        print("imp di oggi: \(ImpegniPerOg.count)")
        dataDiOggiTitolo.text! = getDateOutput(date: date, format: "EEEE dd MMMM")
        getloaded()
    }
    
    func getImpegForData(date: Date)->[Impegno]{
        //CoreDataController.shared.
        var localImp = [Impegno]()
        let dt = dateFromString(format: "EEEE dd MMMM yyyy", date: formatDate(format: "EEEE dd MMMM yyyy", date: date))
        let current = CoreDataController.shared.caricaTuttiGliImpegni()
        for x in current{
            if dt == dateFromString(format: "EEEE dd MMMM yyyy", date: x.perData!){
                localImp.append(x)
            }
        }
        return localImp
    }
   
    
    @IBAction func dayBeforeAc(_ sender: Any) {
        date = date.dayBefore
        dataDiOggiTitolo.text! = getDateOutput(date: date, format: "EEEE dd MMMM")
        currentData = dataModelBullet()
        getloaded()
        
    }
    @IBAction func dayAfAc(_ sender: Any) {
        date = date.dayAfter
        dataDiOggiTitolo.text! = getDateOutput(date: date, format: "EEEE dd MMMM")
        currentData = dataModelBullet()
        getloaded()
        
    }
    
    func saveBullet(withArray: [String], withBoolList: [Bool]){
        let dat = formatDate(format: "yyyy-MM-dd", date: date)
        CoreDataController.shared.newBullet(date: dat, idOfBullet: UUID(), actDat: withArray, doneList: withBoolList)
        let bulletss = CoreDataController.shared.BulletsPerData(data: formatDate(format: "yyyy-MM-dd", date: date))
        bulletPerToday = bulletss[0]
        currentData.stringArray = bulletPerToday.actualContent as? [String]
        currentData.boolArray = bulletPerToday.doneList as? [Bool]
        print(currentData.stringArray)
        print(currentData.boolArray)
        tableView.reloadData()
    }
    
    func getloaded(){
        let bulletss = CoreDataController.shared.BulletsPerData(data: formatDate(format: "yyyy-MM-dd", date: date))
        if bulletss.count == 0{
            print("new bullet")
            saveBullet(withArray: [""], withBoolList: [false])
        }else{
            print("already bullet")
            bulletPerToday = bulletss[0]
            currentData.stringArray = bulletPerToday.actualContent as? [String]
            currentData.boolArray = bulletPerToday.doneList as? [Bool]
            tableView.reloadData()
            print(currentData)
        }
    }

}

extension bulletForDayVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tot row fo tod = \(currentData.stringArray.count + ImpegniPerOg.count)")
        return currentData.stringArray.count + ImpegniPerOg.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        if indexPath.row > currentData.stringArray.count-1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCellBull") as! skeletonCell
            let imIndex = indexPath.row-currentData.stringArray.count
            print("im ind \(imIndex)")
            print(ImpegniPerOg[imIndex])
            cell.model = skeletonModel(ImpegniPerOg[imIndex])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "bulletCell") as! bulletCell
        cell.label.text! = currentData.stringArray[indexPath.row]
        let isDone = currentData.boolArray[indexPath.row]
        if indexPath.row == currentData.stringArray.count-1{
            cell.label.becomeFirstResponder()
        }
        if isDone{
            cell.checkedButton?.setImage(UIImage(named: "tickBull"), for: .normal)
        }else{
            print("\(isDone) in tableView")
            cell.checkedButton?.setImage(UIImage(named: "nottickBull"), for: .normal)
        }
        cell.indexPath = indexPath
        cell.delegateForAdd = self
        return cell
    }
}

extension bulletForDayVC: addingdata{

    
    func didDeleteTheBull(at: IndexPath) {
        print("bckspc pressed, deleting row!!!!")
        if at.row == 0{
            return
        }
        let afterText = currentData.stringArray[at.row]
        if afterText.count > 0{
            currentData.stringArray[at.row-1] += " \(afterText)"
        }
        currentData.stringArray[at.row] = " "
        currentData.stringArray.remove(at: at.row)
        currentData.boolArray.remove(at: at.row)
        bulletPerToday.actualContent = currentData.stringArray as NSObject
        bulletPerToday.doneList = currentData.boolArray as NSObject
        updateBulletInCore()
        tableView.reloadData()
        var ro = at.row
        if ro == 0{
            ro += 1
        }
        let cell = tableView.cellForRow(at: IndexPath(row: ro-1, section: 0)) as! bulletCell
        cell.label.becomeFirstResponder()
    }
    
    func didPressReturn(at: IndexPath, atPos: Int) {
        print("pressedReturn")
        let thisrow = currentData.stringArray[at.row]
        let index = thisrow.index(thisrow.startIndex, offsetBy: atPos)
        let stringAfterRetPoint = thisrow[index...]
        
        //var returningData = curre
        currentData.stringArray.insert(String(stringAfterRetPoint), at: at.row+1)
        currentData.stringArray[at.row].removeLast(stringAfterRetPoint.count)
        currentData.boolArray.insert(false, at: at.row+1)
        currentData.stringArray[at.row] += " "
        bulletPerToday.actualContent = currentData.stringArray as NSObject
        bulletPerToday.doneList = currentData.boolArray as NSObject
        updateBulletInCore()
        tableView.reloadData()
        let cell = tableView.cellForRow(at: IndexPath(row: at.row+1, section: 0)) as! bulletCell
        cell.label.becomeFirstResponder()
    }
    func updateBulletInCore(){
        do{
            try bulletPerToday.managedObjectContext!.save()
        } catch{
            print("errore nella modifica del bullet dopo modifica di uitext in cell");
        }
    }
    func didAddData(at: IndexPath, ofContent: String) {
        currentData.stringArray[at.row] = ofContent
        bulletPerToday.actualContent = currentData.stringArray as NSObject
        updateBulletInCore()
        //update the view--------
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        //-------------------
    }
    func didCheck(at: IndexPath, value: Bool) {
        print("checked!!!!!! at \(at.row) valuing: \(value)")
        currentData.boolArray[at.row] = value
        bulletPerToday.doneList = currentData.boolArray as NSObject
        updateBulletInCore()
    
        //tableView.beginUpdates()
        //tableView.endUpdates()
    }
    
    
}

protocol addingdata{
    func didAddData(at: IndexPath, ofContent: String)
    func didPressReturn(at: IndexPath, atPos: Int)
    func didDeleteTheBull(at: IndexPath)
    func didCheck(at: IndexPath, value: Bool)
}

class bulletCell: UITableViewCell, UITextViewDelegate{
    @IBOutlet weak var checkedButton: UIButton?
    @IBOutlet weak var label: UITextView!
    var indexPath: IndexPath!
    var delegateForAdd: addingdata!
    
    override func awakeFromNib() {
        label.delegate = self
    }
    @IBAction func didCheck(_ sender: Any) {
        var val = true
        let chk = currentData.boolArray[indexPath.row]
        if chk{
            print("falsing")
            val = false
            checkedButton?.setImage(UIImage(named: "nottickBull"), for: .normal)
        }else{
            print("truing")
            val = true
            checkedButton?.setImage(UIImage(named: "tickBull"), for: .normal)
        }
        delegateForAdd.didCheck(at: indexPath, value: val)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegateForAdd.didAddData(at: indexPath, ofContent: textView.text!)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            print("is Enter")
            textView.resignFirstResponder()
            delegateForAdd.didPressReturn(at: indexPath, atPos: range.location)
        }
        
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                let nextStr = textView.text!
                let ind = nextStr.index(nextStr.startIndex, offsetBy: range.location)
                let befSt = nextStr[..<ind]
                if befSt.count == 0{
                    delegateForAdd.didDeleteTheBull(at: indexPath)
                }
            }
        }
        return true
    }
    
}
