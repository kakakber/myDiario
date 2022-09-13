//
//  SettingsVC.swift
//  myDiario
//
//  Created by Enrico on 12/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.isEditing = true
        setUp()
    }
    
    var materie: [String] = []
    var tipi: [String] = []
    
    func setUp(){
        materie = UserDefaults.standard.stringArray(forKey: "materieKey") ?? []
        tipi = UserDefaults.standard.stringArray(forKey: "tipiKey") ?? []
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 231
        default:
            return UITableView.automaticDimension
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Aspetto"
        case 1:
            return "Materie"
        default:
            return "Tipi"
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return materie.count + 1
        default:
            return tipi.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "aspettoCell") as! aspettoCell
            return cell
        case 1:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "matCell")
            if indexPath.row == materie.count{
                cell.textLabel?.textColor = UIColor.systemBlue
                cell.textLabel?.text = "Aggiungi materia..."
                //cell.isEditing = false
                return cell
            }
            //cell.editi
            //cell.isEditing = true
            cell.textLabel?.text = materie[indexPath.row].capitalizingFirstLetter()
            return cell
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "matCell")
            if indexPath.row == tipi.count{
                cell.textLabel?.textColor = UIColor.systemBlue
                cell.textLabel?.text = "Aggiungi tipo..."
                return cell
            }
            cell.textLabel?.text = tipi[indexPath.row].capitalizingFirstLetter()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        case 1:
            if indexPath.row == materie.count{
                return false
            }
        default:
            if indexPath.row == tipi.count{
                return false
            }
        }
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1{
                materie.remove(at: indexPath.row)
                UserDefaults.standard.set(self.materie, forKey: "materieKey")
                print("removed for materie")
            }else{
                tipi.remove(at: indexPath.row)
                UserDefaults.standard.set(self.tipi, forKey: "tipiKey")
                print("removed for tipi")
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.section {
        case 0:
            return UITableViewCell.EditingStyle.none
        case 1:
            if indexPath.row == materie.count{
                return UITableViewCell.EditingStyle.none
            }
        default:
            if indexPath.row == tipi.count{
                return UITableViewCell.EditingStyle.none
            }
        }
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            addDat(materia: true)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            addDat(materia: false)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            return
        }
    }
    
    func addDat(materia: Bool) {
        
        var title = "Aggiungi una materia:"
        if !materia{
            title = "Aggiungi un tipo:"
        }
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Aggiungi", style: .cancel) { [unowned ac] _ in
            let answer = ac.textFields![0]
            if materia{
                self.materie.append(answer.text!.capitalizingFirstLetter()); UserDefaults.standard.set(self.materie, forKey: "materieKey")
                print("added \(answer.text!) for materie")
            }else{
                self.tipi.append(answer.text!.capitalizingFirstLetter()); UserDefaults.standard.set(self.tipi, forKey: "tipiKey")
                print("added \(answer.text!) for tipi")
            }
            self.tableView.reloadData()
        }
        let nothingAc = UIAlertAction(title: "Annulla", style: .default, handler: nil)
        ac.addAction(submitAction)
        ac.addAction(nothingAc)

        present(ac, animated: true)
    }
    
}

class aspettoCell: UITableViewCell{
    @IBOutlet weak var skeletonSelOut: UIButton!
    @IBOutlet weak var bubblySelOut: UIButton!
    
    @IBAction func skeletonSelAct(_ sender: Any) {
        let status = UserDefaults.standard.bool(forKey: "skeleton")
        if status == false{
            UserDefaults.standard.set(true, forKey: "skeleton")
            skeletonSelOut.setImage(UIImage(named: "checked"), for: .normal)
            bubblySelOut.setImage(UIImage(named: "notChecked"), for: .normal)
        }
        print(UserDefaults.standard.bool(forKey: "skeleton"))
    }
    @IBAction func bubblySelAct(_ sender: Any) {
        let status = UserDefaults.standard.bool(forKey: "skeleton")
        if status == true{
            UserDefaults.standard.set(false, forKey: "skeleton")
            bubblySelOut.setImage(UIImage(named: "checked"), for: .normal)
            skeletonSelOut.setImage(UIImage(named: "notChecked"), for: .normal)
        }
        print(UserDefaults.standard.bool(forKey: "skeleton"))
    }
    
    override func layoutSubviews() {
        print("awake")
        if !isKeyPresentInUserDefaults(key: "skeleton"){
            UserDefaults.standard.set(true, forKey: "skeleton")
            print("in: \(UserDefaults.standard.bool(forKey: "skeleton"))")
        }
        print(UserDefaults.standard.bool(forKey: "skeleton"))
        let status = UserDefaults.standard.bool(forKey: "skeleton")
        switch status {
        case true:
            skeletonSelOut.setImage(UIImage(named: "checked"), for: .normal)
            bubblySelOut.setImage(UIImage(named: "notChecked"), for: .normal)
        default:
            skeletonSelOut.setImage(UIImage(named: "notChecked"), for: .normal)
            bubblySelOut.setImage(UIImage(named: "checked"), for: .normal)
        }
    }
    
}
