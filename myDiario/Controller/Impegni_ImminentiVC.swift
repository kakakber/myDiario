//
//  Impegni_ImminentiVC.swift
//  AppStudente
//
//  Created by Enrico Alberti on 02/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework
import SwiftyJSON

var trAg = false


/*
class imPcld : UITableViewCell{
    
    /*@IBOutlet weak var tipo: UILabel!
     @IBOutlet weak var profe: UILabel!
     @IBOutlet weak var desc: UITextView!
     @IBOutlet weak var titolo: UILabel!
     @IBOutlet weak var orario: UILabel!*/
    
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var profe: UILabel!
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var orario: UILabel!
    
}


class momImp{
    var id = String()
    var date = Date()
}

class Impegni_ImminentiVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MoreButtonsDelegate{
    
    func firstSel(at index: IndexPath) {
        //
        isAgenda = false
        cariAgView.isHidden = true
        order_Imp_Array()
        tableView.reloadData()
    }
    
    func seconSel(at index: IndexPath) {
        //
        cariAgView.isHidden = false
        isAgenda = true
        setUpAgenda()
        cariAg.isHidden = false
    }
    
    func AddTapped(at index: IndexPath) {
        
    }
    
    @IBOutlet weak var noEventiView: UIView!
    
    var colori : [UIColor] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    func getColor(from: UIColor, to: UIColor)->UIColor{
        
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }
    @IBOutlet weak var cariAgView: UIView!
    @IBOutlet weak var cariAg: UIActivityIndicatorView!
    
    var impegni : [Impegno] = []
    override func viewDidAppear(_ animated: Bool) {
        print("app")
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if trAg {
            cariAgView.isHidden = false
            isAgenda = true
            setUpAgenda()
            cariAg.isHidden = false
        }
        isAgenda = false
        UIApplication.shared.applicationIconBadgeNumber = 0
        order_Imp_Array()
        self.tabBarController?.tabBar.isHidden = false
        //formare i possibili colori
        colori = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
        
        tableView.estimatedRowHeight = 210
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
    }
    var arrayDiImpegni : [Impegno] = []
    
    override func viewWillAppear(_ animated: Bool) {
        noEventiView.isHidden = true
        
        arrayDiImpegni = CoreDataController.shared.caricaTuttiGliImpegni()
        tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func end(_ sender: Any) {
        //navigationController?.setNavigationBarHidden(true, animated: false)
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    private func makeColor(r: Double, g: Double, b: Double)->UIColor{
        //funzione per creare velocemente colori con rgb
        var retCol = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1.0)
        return retCol
    }
    
    
    func order_Imp_Array(){
        //ordinare gli impegni in un array
        arrayDiImpegni = CoreDataController.shared.caricaTuttiGliImpegni()
        var sorArray: [momImp] = [] //array per ordinare impegni
        var dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT") // in italiano
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"// yyyy-MM-dd"
        
        for dt in arrayDiImpegni{
            let date = dateFormatter.date(from: dt.perData!)
            if let date = date {
                //creazione di nuovo elemento da aggiungere nell'array
                let newEl = momImp()
                newEl.date = date
                newEl.id = dt.id!
                sorArray.append(newEl)
            }
        }
        let ready = sorArray.sorted(by: { $0.date.compare($1.date) == .orderedAscending })
        
        //ora riordinar con id
        var sosArray : [Impegno] = [] //array per riordinare
        
        for hh in arrayDiImpegni{
            sosArray.append(hh)
        }
        var prog = 0
        for srt in ready{
            //ciclo che rimpiazza gli elementi di ArrayDiImpegni in ordine cronologico
            for old in sosArray{
                if srt.id == old.id{
                    arrayDiImpegni[prog] = old
                }
            }
            prog += 1
        }
        
        let currentDate = Date()
        
        //cancellare elementi precedenti alla data corrente
        sosArray.removeAll()
        for hh in arrayDiImpegni{
            sosArray.append(hh)
        }
        var cont = 0;
        arrayDiImpegni.removeAll()
        
        for elim in sosArray{
            //eliminare tutto da ArrayDiImpegni e riempirlo solo con eventi di date successive a quella corrente
            let date = dateFormatter.date(from: elim.perData!)
            if date! < currentDate{
            }else{
                arrayDiImpegni.append(elim)
            }
            cont += 1
        }
        //linee per widget
        
        filterForWidget()
        
    }
    
    func filterForWidget(){
        var arrayVeri : [Impegno] = [];
        arrayVeri.removeAll()
        for a in arrayDiImpegni{
            if a.tipo?.uppercased() == "VERIFICA"{
                arrayVeri.append(a)
            }
        }
        
        if arrayVeri.count > 0{
            UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[0].materia!.uppercased(), forKey: "PrimoMateria")
            UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[0].descrizione!.capitalizingFirstLetter(), forKey: "PrimoDescrizione")
            UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[0].perData!.capitalizingFirstLetter(), forKey: "PrimoData")
            UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[0].colore!, forKey: "PrimoColore")
            if arrayVeri.count > 1{
                UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[1].materia!.uppercased(), forKey: "SecondoMateria")
                UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[1].descrizione!.capitalizingFirstLetter(), forKey: "SecondoDescrizione")
                UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[1].perData!.capitalizingFirstLetter(), forKey: "SecondoData")
                UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue(arrayVeri[1].colore!, forKey: "SecondoColore")
            }else{
                UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue("nonValidNoMatNoMatSecond", forKey: "SecondoMateria")
            }
        }else{
            
            UserDefaults.init(suiteName: "group.com.liceomascheroni.alberti.mascheroni")?.setValue("nonValidNoMatNoMatFirst", forKey: "PrimoMateria")
        }
    }
    
    @IBOutlet weak var plusBtn: UIView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        order_Imp_Array()
        if isAgenda{
            plusBtn.isHidden = true
            if eventiAgenda.count == 0 {
                noEventiView.isHidden = false
                noevtText.text! = "Non sono presenti eventi futuri in agenda"
            }else{
                noEventiView.isHidden = true
            }
            return eventiAgenda.count + 1
        }else{
            plusBtn.isHidden = false
            noevtText.text! = "Non ci sono eventi in programma"
        }
        if arrayDiImpegni.count == 0{
            noEventiView.isHidden = false
            if isAgenda{
                //noDatDesc.text! = "Non ci sono eventi in agenda per questo giorno"
            }else{
                //noDatDesc.text! = "Non ci sono eventi personali per questo giorno"
            }
            return 1
        }else{
            noEventiView.isHidden = true
            if isAgenda{
                return eventiAgenda.count + 1
            }else{
                return arrayDiImpegni.count + 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        //sistemazione dell'altezza delle celle in base ai 3 tipi di celle
        var retValue = 120.0
        if indexPath.row == 0{
            return 137.0
        }else{
            if indexPath.row == 1{
                if !isAgenda{
                    return 191.0;}else{
                    tableView.estimatedRowHeight = 120
                    tableView.separatorStyle = .singleLineEtched
                    return UITableView.automaticDimension
                }
            }else {
                if !isAgenda{
                    let lessOne = indexPath.row - 1
                    if arrayDiImpegni[indexPath.row-1].perData! == arrayDiImpegni[lessOne-1].perData!{
                        return 143.0
                    }else{
                        return 191.0
                    }
                }else{
                    
                    tableView.estimatedRowHeight = 120
                    tableView.separatorStyle = .singleLine
                    return UITableView.automaticDimension
                    
                }
            }
        }
        
        return CGFloat(retValue)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //cella selezionata
        print("culo")
        if indexPath.row > 0 && !isAgenda{
            materiaV = arrayDiImpegni[indexPath.row-1].materia!
            tipoV = arrayDiImpegni[indexPath.row-1].tipo!
            descrizioneV = arrayDiImpegni[indexPath.row-1].descrizione!
            dataV = arrayDiImpegni[indexPath.row-1].perData!
            idV = arrayDiImpegni[indexPath.row-1].id!
            
            //performSegue(withIdentifier: "selected", sender: nil)
            performSegue(withIdentifier: "toNewRowSel1", sender: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        //nessuna sezione aggiuntiva
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        order_Imp_Array()
        //utilizza il NIB Classi-TableViewCell come base per la presentazione dei dati nella TableView
        
        if indexPath.row == 0{
            //la prima cella non cliccabile è il titolo con la data di oggi
            let cell = Bundle.main.loadNibNamed("ProgrammaOggiCell", owner: self, options: nil)?.first as! ProgrammaOggiCell
            cell.selectionStyle = .none
            cell.upperViewSep.isHidden = true
            
            if isAgenda{
                cell.segmented.selectedIndex = 1
            }
            let date = Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateFormat = "EEEE dd MMMM yyyy"
            
            let risultato = formatter.string(from: date)
            cell.delegate = self
            cell.indexPath = indexPath
            cell.dataDiOggi.text! = risultato
            
            return cell
        }else{
            //se non siamo alla prima cella
            
            if indexPath.row == 1 && !isAgenda{
                //seconda cella
                let cell = Bundle.main.loadNibNamed("Cell1_ConData", owner: self, options: nil)?.first as! Cell1_ConData
                
                FillCell_Type1(cell: cell, indexPath: indexPath, color: UIColor.red)
                
                return cell}
            if isAgenda{
                tableView.estimatedRowHeight = 60
                tableView.rowHeight = UITableView.automaticDimension
                let cell =  tableView.dequeueReusableCell(withIdentifier: "aa", for: indexPath) as! imPcld
                let iq = indexPath.row - 1
                noEventiView.isHidden = true
                if eventiAgenda[iq].materia == ""{
                    cell.titolo.text! = eventiAgenda[iq].autore.lowercased().capitalized
                }
                if eventiAgenda[iq].materia != ""{
                    cell.titolo.text! = "\(eventiAgenda[iq].autore.lowercased().capitalized) ~ \(eventiAgenda[iq].materia)"
                }
                
                switch eventiAgenda[iq].code{
                case "AGNT":
                    cell.tipo.text! = "Annotazione"
                case "AGHW":
                    cell.tipo.text! = "Compiti a casa"
                case "AGCR":
                    cell.tipo.text! = "Prenotazione aula"
                default:
                    cell.tipo.text! = "Annotazione"
                }
                let formatter = DateFormatter()
                
                formatter.dateFormat = "dd MMM yy"
                let hourString = formatter.string(from: eventiAgenda[iq].inizia)
                cell.orario.text! = "\(hourString)"
                
                cell.desc.text! = eventiAgenda[iq].descrizine
                cell.profe.text! = eventiAgenda[iq].autore.lowercased().capitalized
                return cell
            }else{
                //nelle altre celle se la data è uguale alla precedente le unisco.
                let lessOne = indexPath.row - 1
                if arrayDiImpegni[indexPath.row-1].perData! == arrayDiImpegni[lessOne-1].perData!{
                    let cell = Bundle.main.loadNibNamed("Cell2_SenzaData", owner: self, options: nil)?.first as! Cell2_SenzaData
                    
                    FillCell_Type2(cell: cell, indexPath: indexPath)
                    
                    return cell
                }else{
                    let cell = Bundle.main.loadNibNamed("Cell1_ConData", owner: self, options: nil)?.first as! Cell1_ConData
                    
                    FillCell_Type1(cell: cell, indexPath: indexPath, color: UIColor.blue)
                    
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
    }
    var cellaDaEliminare : Int = 0
    
    func eliminaCell(action: UIAlertAction){
        //elimino impegno da Core data e ricarico la view
        let DeleteId = arrayDiImpegni[cellaDaEliminare].id!
        CoreDataController.shared.cancellaImpegno(id: DeleteId)
        arrayDiImpegni = CoreDataController.shared.caricaTuttiGliImpegni()
        self.tableView.reloadData()
        
    }
    
    func infos(action: UIAlertAction){
        idV = arrayDiImpegni[cellaDaEliminare].id!
        materiaV = arrayDiImpegni[cellaDaEliminare].materia!
        tipoV = arrayDiImpegni[cellaDaEliminare].tipo!
        descrizioneV = arrayDiImpegni[cellaDaEliminare].descrizione!
        dataV = arrayDiImpegni[cellaDaEliminare].perData!
        performSegue(withIdentifier: "selected", sender: nil)
    }
    
    func update(id : String, completato : Bool){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.completato = completato
        do {
            try impegno.managedObjectContext!.save()
        } catch {
            print("[CDC] Errore salvataggio impegno modificato")
        }
    }
    
    func CompletatoTapped(at index: IndexPath){
        print("tapped Completato")
        //il pulsante per l'evento completato viene premuto, gestione di esso grafica e nel database
        if arrayDiImpegni[index.row-1].completato == true {
            update(id: arrayDiImpegni[index.row-1].id!, completato: false)
            
            if tableView.cellForRow(at: index) is Cell1_ConData{
                let ib = tableView.cellForRow(at: index) as! Cell1_ConData
                ib.completatoButton.setImage(#imageLiteral(resourceName: "VnotSelected"), for: .normal)
                ib.completatoLabel.text! = ""
            }else{
                let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
                ib.completatoButton.setImage(#imageLiteral(resourceName: "VnotSelected"), for: .normal)
                ib.completatoLabel.text! = ""
            }
        }else{
            update(id: arrayDiImpegni[index.row-1].id!, completato: true)
            if tableView.cellForRow(at: index) is Cell1_ConData{
                let ib = tableView.cellForRow(at: index) as! Cell1_ConData
                ib.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
                ib.completatoLabel.text! = "completato"
            }else{
                let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
                ib.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
                ib.completatoLabel.text! = "completato"
            }
        }
    }
    
    func MoreTapped(at index: IndexPath) {
        //moreButton viene premuto, func ottenuta dal delegate della classe MoreButtonsDelegate
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        cellaDaEliminare = index.row-1
        menu.addAction(UIAlertAction(title: "Informazioni", style: .default, handler: self.infos))
        menu.addAction(UIAlertAction(title: "Elimina", style: .destructive, handler: self.eliminaCell))
        menu.addAction(UIAlertAction(title: "Indietro", style: .cancel, handler: nil))
        
        if let presenter = menu.popoverPresentationController {
            
            if tableView.cellForRow(at: index) is Cell2_SenzaData{
                let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
                presenter.sourceView = ib.ibadView
            }else{
                let ic = tableView.cellForRow(at: index) as! Cell1_ConData
                presenter.sourceView = ic.ipadSelectView
            }
            
            
        }
        
        self.present(menu, animated: true, completion: nil)
        print("more premuto at \(index.row-1)")
    }
    
    func FillCell_Type1(cell : Cell1_ConData, indexPath: IndexPath, color : UIColor){
        //funzione per riempire cella di tipo 1
        cell.data.text! = "Per \(arrayDiImpegni[indexPath.row-1].perData!)"
        cell.data.text!.removeLast(); cell.data.text!.removeLast(); cell.data.text!.removeLast(); cell.data.text!.removeLast();
        cell.data.text!.capitalizeFirstLetter()
        cell.view.backgroundColor = color
        cell.materia.text! = arrayDiImpegni[indexPath.row-1].materia!
        cell.materia.text = cell.materia.text?.uppercased()
        cell.tipo.text! = arrayDiImpegni[indexPath.row-1].tipo!
        cell.tipo.text = cell.tipo.text?.uppercased()
        if arrayDiImpegni[indexPath.row-1].completato == true{
            cell.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
            cell.completatoLabel.text! = "completato"
        }
        cell.descrizione.text! = arrayDiImpegni[indexPath.row-1].descrizione!
        cell.view.backgroundColor = colori[Int(arrayDiImpegni[indexPath.row-1].colore!)!]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
    }
    
    func FillCell_Type2(cell : Cell2_SenzaData, indexPath: IndexPath){
        //riempire la cella di tipo 2, senza data
        cell.view.backgroundColor = colori[Int(arrayDiImpegni[indexPath.row-1].colore!)!]
        cell.materia.text! = arrayDiImpegni[indexPath.row-1].materia!
        cell.materia.text = cell.materia.text?.uppercased()
        if arrayDiImpegni[indexPath.row-1].completato == true{
            cell.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
            cell.completatoLabel.text! = "completato"
        }
        cell.tipo.text! = arrayDiImpegni[indexPath.row-1].tipo!
        cell.tipo.text = cell.tipo.text?.uppercased()
        cell.descrizione.text! = arrayDiImpegni[indexPath.row-1].descrizione!
        cell.delegate = self
        cell.indexPath = indexPath
        cell.selectionStyle = .none
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    
    
    func setUpAgenda(){
        self.textInCar.text! =  ""
        if isKeyPresentInUserDefaults(key: "id") && isKeyPresentInUserDefaults(key: "password") && isKeyPresentInUserDefaults(key: "token"){
            //utente ha gia fatto l'accesso, controllo il token
            print("\nutente ha fatto accesso, controllo token")
            tokenz = UserDefaults.standard.object(forKey: "token") as! String
            statoToken(resource: "agenda", id: UserDefaults.standard.object(forKey: "id") as! String, psw: UserDefaults.standard.object(forKey: "password") as! String)
        }else{
            //altrimenti gli faccio fare l'accesso
            print("nessun dato, faccio fare accesso")
            self.cariAgView.isHidden = false
            self.textInCar.text! =  "Vai nella sezione \"Registro elettronico\" e effettua l'accesso con classeviva per vedere gli eventi in agenda"
            cariAg.isHidden = true
            //salvo in USERDefaults
            
        }
    }
    var tokenz = ""
    func statoToken(resource: String, id : String, psw: String){//ritorna i secondi prima che il token scada
        //resource es: voti, avvisi
        //https://web.spaggiari.eu/rest/v1/auth/status
        
        let url2 = URL(string: "https://web.spaggiari.eu/rest/v1/auth/status")!
        
        var request2 = URLRequest(url: url2)
        request2.httpMethod = "GET"
        
        request2.addValue("+zorro+", forHTTPHeaderField: "Z-Dev-ApiKey")
        request2.addValue("zorro/1.0", forHTTPHeaderField: "User-Agent")
        request2.addValue(tokenz, forHTTPHeaderField: "Z-Auth-Token")
        var rs : Double = 6
        var idZh = ""
        let task2 = URLSession.shared.dataTask(with: request2) { data, response, error in
            //print(String(data: data!, encoding: .utf8))
            if let response = response, let data = data {
                do {
                    let json = try JSON(data: data)
                    
                    rs =  json["status"]["remains"].doubleValue
                    idZh = json["status"]["ident"].stringValue
                    
                    print(rs)
                    if rs == 0{
                        print("\n\ninvalid token")
                        //get new token
                        self.log(id: idZh, password: psw)
                    }else{
                        print("\n\nvalid token mancano \(rs/60) minuti")
                        //token valido procedo
                        
                        self.getAgenda(id: idZh, token: self.tokenz)
                        
                    }
                    
                }
                catch let error as NSError{
                    print(error)
                }
                
                
            } else {
                print(error)
            }
            
        }
        
        task2.resume()
        
    }
    
    @IBOutlet weak var noevtText: UITextView!
    
    
    @IBOutlet weak var textInCar: UITextView!
    
    func log(id : String, password: String){
        print("nuovo log per token")
        
        let url = URL(string: "https://web.spaggiari.eu/rest/v1/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("+zorro+", forHTTPHeaderField: "Z-Dev-ApiKey")
        request.addValue("zorro/1.0", forHTTPHeaderField: "User-Agent")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let json: [String: Any] = ["uid":id, "pass": password]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response, let data = data {
                print(response)
                print(String(data: data, encoding: .utf8))
                do {
                    let parsedData = try JSON(data: data)
                    
                    self.tokenz =  parsedData["token"].stringValue
                    
                    let info = parsedData["info"].stringValue
                    
                    print(info)
                    if info != ""{
                        print("\n\nerrore nel logIn")
                        DispatchQueue.main.async {
                            self.cariAgView.isHidden = false
                            self.textInCar.text! =  "Vai nella sezione \"Registro elettronico\" e effettua l'accesso con classeviva per vedere gli eventi in agenda"
                            self.cariAg.isHidden = true
                            //self.voti.removeAll()
                            //self.tableView.reloadData()
                        }
                    }else{
                        print("\n\ntutto ok prendo agenda e aggiungo UserDefaults")
                        DispatchQueue.main.async {
                        }
                        UserDefaults.standard.set(id, forKey: "id")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(self.tokenz, forKey: "token")
                        self.getAgenda(id: id, token: self.tokenz)
                    }
                    //self.getVotiData()
                    
                } catch let error as NSError {
                    print(error)
                }
            } else {
                print(error)
            }
        }
        
        task.resume()
        print("\n\n\n")
        
        
    }
    
    func getAgenda(id: String, token: String){
        
        var idinurl = id
        
        idinurl.removeFirst()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "it_IT")
        formatter.dateFormat = "yyyyMMdd"
        
        let today = Date()
        let risultato = formatter.string(from: Date())
        
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let dscAA = Date()
        let sec = dscAA.monthAfter
        let frt = formatter.string(from: sec)
        
        let url2 = URL(string: "https://web.spaggiari.eu/rest/v1/students/\(idinurl)/agenda/all/\(risultato)/\(frt)")!
        
        //URL(string: "https://web.spaggiari.eu/rest/v1/students/\(idinurl)/agenda/all/20180510/20180530")!
        //"https://web17.spaggiari.eu/rest/v1/students/\(idinurl)/agenda/all/\(risultato)/\(risultato)"
        
        var request2 = URLRequest(url: url2)
        request2.httpMethod = "GET"
        
        request2.addValue("+zorro+", forHTTPHeaderField: "Z-Dev-ApiKey")
        request2.addValue("zorro/1.0", forHTTPHeaderField: "User-Agent")
        request2.addValue(token, forHTTPHeaderField: "Z-Auth-Token")
        eventiAgenda.removeAll()
        let task2 = URLSession.shared.dataTask(with: request2) { data, response, error in
            print(response)
            //print(String(data: data!, encoding: .utf8))
            if let response = response, let data = data {
                
                do {
                    
                    let json = try JSON(data: data)
                    
                    let evtId = json["agenda"].arrayValue.map({$0["evtId"].stringValue})
                    let evtCode = json["agenda"].arrayValue.map({$0["evtCode"].stringValue})
                    let evtBegin = json["agenda"].arrayValue.map({$0["evtDatetimeBegin"].stringValue})
                    let evtEnd = json["agenda"].arrayValue.map({$0["evtDatetimeEnd"].stringValue})
                    let fullDay = json["agenda"].arrayValue.map({$0["isFullDay"].boolValue})
                    let notes = json["agenda"].arrayValue.map({$0["notes"].stringValue})
                    let autore = json["agenda"].arrayValue.map({$0["authorName"].stringValue})
                    let classDesc = json["agenda"].arrayValue.map({$0["classDesc"].stringValue})
                    let materia = json["agenda"].arrayValue.map({$0["subjectDesc"].stringValue})
                    
                    var f = 0
                    for b in evtId{
                        var dateFormatter = DateFormatter()
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        //dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        let date = dateFormatter.date(from:evtBegin[f])!
                        let dat2 = dateFormatter.date(from:evtEnd[f])!
                        /*let calendar = Calendar.current
                         let components = calendar.dateComponents([.hour], from: date)
                         let cmnts2 = calendar.dateComponents([.hour], from: dat2)
                         let initDate = calendar.date(from:components)
                         let finD = calendar.date(from:cmnts2)*/
                        
                        
                        var newAgenda  = eventoAgenda(id: b, code: evtCode[f], inizia: date, finisce: dat2, isFullDay: fullDay[f], descrizine: notes[f], autore: autore[f], classDesc: classDesc[f], materia: materia[f])
                        self.eventiAgenda.append(newAgenda)
                        f += 1
                    }
                    
                    self.eventiAgenda = self.eventiAgenda.sorted(by: { $0.inizia.compare($1.inizia) == .orderedAscending })
                    print(self.eventiAgenda)
                    DispatchQueue.main.async {
                        self.isAgenda = true
                        //self.loadingAg.isHidden = true
                        self.cariAgView.isHidden = true
                        self.tableView.reloadData()
                    }
                    
                }
                catch let error as NSError{
                    print(error)
                }
                
            } else {
                print(error)
            }
        }
        
        task2.resume()
        
    }
    
    var isAgenda = false
    var eventiAgenda : [eventoAgenda] = []
    
    struct eventoAgenda{
        var id : String
        var code : String
        var inizia : Date
        var finisce : Date
        var isFullDay : Bool
        var descrizine : String
        var autore : String
        var classDesc : String
        var materia : String
    }
    
}*/

