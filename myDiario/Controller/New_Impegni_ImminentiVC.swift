//
//  New_Impegni_ImminentiVC.swift
//  myDiario
//
//  Created by Enrico on 09/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit
import ChameleonFramework
import DZNEmptyDataSet
import CloudKit
import CoreData


class New_Impegni_ImminentiVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var today: UILabel!
    
    
    func setUp(){
         print("setting up")
        today.text! = formatDate(format: "EEEE dd MMMM yyyy", date: Date()).capitalizingFirstLetter()
        let provImp = CoreDataController.shared.caricaTuttiGliImpegni()
        print("non filtered: \(provImp.count)")
        
        //converto in data e filtro a partire da data corrente
        tuttiImp = sortImpArrayByDate(imp: provImp, withLimit: true, limitingFrom: Date())
        print("filtered: \(tuttiImp.count)")
        tableView.reloadData()
    }
                  
    var skeleton = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        self.tabBarController?.tabBar.isHidden = false
        tableView.estimatedRowHeight = 100
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(back), name: Notification.Name("GettingBackImm"), object: nil)
    }
    
    @objc func back(_ notification:Notification) {
        // Do something now
        setUp()
    }

}

fileprivate var tuttiImp = [Impegno]()

extension New_Impegni_ImminentiVC: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("\n\nWILL CHANGE CONTENT\n\n")
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.reloadData()
        print("\n\nchanged SHIT!!!!!\n\n")
    }
}

extension New_Impegni_ImminentiVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tuttiImp.count == 0 {
        print("empty")
        }
        return tuttiImp.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*materiaV = tuttiImp[indexPath.row].materia!
        tipoV = tuttiImp[indexPath.row].tipo!
        descrizioneV = tuttiImp[indexPath.row].descrizione!
        dataV = tuttiImp[indexPath.row].perData!
        idV = tuttiImp[indexPath.row].id!
        performSegue(withIdentifier: "selEc", sender: nil)*/
        performSegue(withIdentifier: "infoEvt", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         guard segue.identifier == "infoEvt" else {return}
        if segue.identifier == "ImmToBullet"{
             let targetController = segue.destination as! bulletForDayVC
            targetController.date = Date()
            return
        }
        let targetController = segue.destination as! SelectedRowFinal
        if let indexPath = tableView.indexPathForSelectedRow{
            targetController.eventoScelto = EventoDiario(id: tuttiImp[indexPath.row].id!, tipo: tuttiImp[indexPath.row].tipo!, data:  tuttiImp[indexPath.row].perData!, descrizione: tuttiImp[indexPath.row].descrizione!, materia: tuttiImp[indexPath.row].materia!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if skeleton{
            if indexPath.row > 0 && tuttiImp[indexPath.row].perData! == tuttiImp[indexPath.row-1].perData!{
                let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCell") as! skeletonCell
                cell.model = skeletonModel(tuttiImp[indexPath.row])
                cell.viewColor.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCellWithDate") as! skeletonCellWithDate
                cell.model = skeletonModel(tuttiImp[indexPath.row])
                cell.viewColor.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
                return cell
            }
        }
        
        if indexPath.row > 0 && tuttiImp[indexPath.row].perData! == tuttiImp[indexPath.row-1].perData!{
            /*let cell = Bundle.main.loadNibNamed("Cell2_SenzaData", owner: self, options: nil)?.first as! Cell2_SenzaData
            cell.model = bubblyModel(tuttiImp[indexPath.row])
            cell.view.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
            cell.delegate = self
            cell.indexPath = indexPath*/
            let cell = tableView.dequeueReusableCell(withIdentifier: "bubblyCell") as! bubblyCell
            cell.model = skeletonModel(tuttiImp[indexPath.row])
            cell.viewColor.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
            return cell
        }
        /*let cell = Bundle.main.loadNibNamed("Cell1_ConData", owner: self, options: nil)?.first as! Cell1_ConData
        cell.model = bubblyModel(tuttiImp[indexPath.row])
        cell.view.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
        cell.indexPath = indexPath
        cell.delegate = self*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "bubblyCellWithDate") as! bubblyCellWithDate
        cell.model = skeletonModel(tuttiImp[indexPath.row])
        cell.viewColor.layer.backgroundColor = colorz[Int(tuttiImp[indexPath.row].colore!)!].cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataController.shared.cancellaImpegno(id: tuttiImp[indexPath.row].id!)
            tuttiImp.removeAll()
            setUp()
        }
    }
    
    
}

extension New_Impegni_ImminentiVC: MoreButtonsDelegate{
    func MoreTapped(at index: IndexPath) {
        //
    }
    
    func CompletatoTapped(at index: IndexPath) {
        CoreDataController.shared.completaImpegno(id: tuttiImp[index.row].id!, completato: !tuttiImp[index.row].completato)
        setUp()
    }
    
    func firstSel(at index: IndexPath) {
        //
    }
    
    func seconSel(at index: IndexPath) {
        //
    }
    
    
}

extension New_Impegni_ImminentiVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "\nNessun impegno imminente"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)

    }
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "diary")
    }
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Premi il pulsante + per aggiungerne uno"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
}


var colorz : [UIColor] = []
//gestione colori


class skeletonCell: UITableViewCell{
    
    @IBOutlet weak var descrizione: UITextView!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var viewColor: UIView!
    
    var model: skeletonModel!{
        didSet{
            descrizione.text! = model.descrizione
            tipo.text! = model.tipo
            materia.text! = model.materia
        }
    }
}


class skeletonCellWithDate: UITableViewCell{
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var descrizione: UITextView!
    @IBOutlet weak var viewColor: UIView!
    
    var model: skeletonModel!{
        didSet{
            descrizione.text! = model.descrizione
            tipo.text! = model.tipo
            materia.text! = model.materia
            date.text! = model.data
        }
    }
}

class bubblyCellWithDate: UITableViewCell{
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var descrizione: UITextView!
    @IBOutlet weak var viewColor: UIView!
    
    var model: skeletonModel!{
        didSet{
            descrizione.text! = model.descrizione
            tipo.text! = model.tipo
            materia.text! = model.materia
            date.text! = model.data
        }
    }
    
}

class bubblyCell: UITableViewCell{
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var descrizione: UITextView!
    @IBOutlet weak var viewColor: UIView!
    
    var model: skeletonModel!{
        didSet{
            descrizione.text! = model.descrizione
            tipo.text! = model.tipo
            materia.text! = model.materia
        }
    }
}

extension New_Impegni_ImminentiVC{
    override func viewWillAppear(_ animated: Bool) {
        if !isKeyPresentInUserDefaults(key: "skeleton"){
                  UserDefaults.standard.set(true, forKey: "skeleton")
                  print("never defined skeleton")
              }
        skeleton = UserDefaults.standard.bool(forKey: "skeleton")
        print("nibbed is \(skeleton)")
        self.tabBarController?.tabBar.isHidden = false
        setUp()
        colorz = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
    }
    func getColor(from: UIColor, to: UIColor)->UIColor{
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }
}


