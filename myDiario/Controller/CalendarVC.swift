//
//  CalendarioVC.swift
//  AppStudente
//
//  Created by Enrico Alberti on 02/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.



import UIKit
import FSCalendar
import ChameleonFramework
import SwiftyJSON

//------------ variabili per aggiungere data da giorno in Calendar
var newEventInDayTransition = Date()
var IsDate : Bool = false
//----------------------------------------------------------------

class agCel : UITableViewCell{
    
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var profe: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var titolo: UILabel!
    @IBOutlet weak var orario: UILabel!
    
}

class CalendarVC: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate, MoreButtonsDelegate, addButtonProtocol{
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var noEventsView: UIView!
    
    @IBOutlet weak var plusButtonB: UIButton!
    @IBOutlet weak var besidePlusView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    var allImpQ : [Impegno] = []
    @IBOutlet weak var dayInView: UILabel!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        
        self.navigationItem.title = self.getMonth().capitalizingFirstLetter()
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
    var ImpPerGiornata : [Impegno] = []
    
    var selectedDay : Date = Date()
    
    func SetDayImp(day : Date){
        ImpPerGiornata.removeAll()
        let tuttiImp = CoreDataController.shared.caricaTuttiGliImpegni()
        //carico le date degli impegni del giorno 'day'
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT") // in italiano
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        for iter in tuttiImp{
            let data = dateFormatter.date(from: iter.perData!)
            if data == day{
                ImpPerGiornata.append(iter)
            }
        }
        tableView.reloadData()
        print("gli impegni del giorno \(day), sono \(ImpPerGiornata.count)")
    }
    
    var jeff = 0
    func rotateBarButton() {
        if jeff % 2 == 0{
            self.barButton.customView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }else{
            self.barButton.customView?.transform = CGAffineTransform(rotationAngle: 0)
        }
        jeff += 1
    }
    
    func firstSel(at index: IndexPath) {
        print("first")
        noViewCRR.isHidden = true
        isAgenda = false
        SetDayImp(day: selectedDay)
        loadingAg.isHidden = true
        self.calendar.reloadData()
    }
    
    var isAgenda = false
    
    func seconSel(at index: IndexPath) {
        print("second")
        loadingAg.isHidden = false
        isAgenda = true
        setUpAgenda()
    }
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    var tokenz = ""
    func setUpAgenda(){
        self.noViewCRR.isHidden = true
        if isKeyPresentInUserDefaults(key: "id") && isKeyPresentInUserDefaults(key: "password") && isKeyPresentInUserDefaults(key: "token"){
            //utente ha gia fatto l'accesso, controllo il token
            print("\nutente ha fatto accesso, controllo token")
            tokenz = UserDefaults.standard.object(forKey: "token") as! String
            statoToken(resource: "agenda", id: UserDefaults.standard.object(forKey: "id") as! String, psw: UserDefaults.standard.object(forKey: "password") as! String)
        }else{
            //altrimenti gli faccio fare l'accesso
            print("nessun dato, faccio fare accesso")
            self.noViewCRR.isHidden = false
            //salvo in USERDefaults
            
        }
    }
    
    @IBAction func ext(_ sender: Any) {
        //navigationController?.setNavigationBarHidden(true, animated: false)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func ButtonAction(sender: UIButton){
        self.rotateBarButton()
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    func setButtonNavBar(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Create new button & set its frame
        button.setImage(UIImage(named: "down-arrow"), for: .normal) // Assign an image
        button.addTarget(self, action: #selector(ButtonAction), for: .touchUpInside)
        
        barButton.customView = button // Set as barButton's customView
        
    }
    
    
    var colori : [UIColor] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        besidePlusView.clipsToBounds = false
        besidePlusView.layer.shadowColor = UIColor.lightGray.cgColor
        besidePlusView.layer.shadowOpacity = 0.4
        besidePlusView.layer.shadowOffset = CGSize.zero
        besidePlusView.layer.shadowRadius = 5
        besidePlusView.layer.shadowPath = UIBezierPath(roundedRect: besidePlusView.bounds, cornerRadius: plusButtonB.frame.width/2).cgPath
        
        besidePlusView.addSubview(plusButtonB)
        
        
        colori = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
        
        setButtonNavBar()
        print(colori.count)
        
        self.tabBarController?.tabBar.isHidden = false
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT")
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        let strDate = dateFormatter.string(from: today)
        
        
        dateFormatter.locale = Locale(identifier: "it_IT") // in italiano
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        let data = dateFormatter.date(from: strDate)
        
        SetDayImp(day: data!)
        
        selectedDay = data!
        
        self.calendar.select(data!)
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        tableView.delegate = self
        
        
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        self.navigationItem.title = getMonth().capitalizingFirstLetter()
        if #available(iOS 11.0, *) {
            //navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getColor(from: UIColor, to: UIColor)->UIColor{
        
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }
    
    deinit {
        print("\(#function)")
    }
    
    func getMonth() -> String{
        let currentPageDate = calendar.currentPage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let nameOfMonth = dateFormatter.string(from: currentPageDate)
        
        return nameOfMonth
    }
    
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT") // in italiano
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        return dateFormatter
    }()
    
    func caricaDate() -> [String]{
        
        let impegni = CoreDataController.shared.caricaTuttiGliImpegni()
        var exit : [String] = []
        for i in impegni{
            exit.append(i.perData!)
        }
        
        return exit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SetDayImp(day: selectedDay)
        self.calendar.reloadData()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func VeriInDate(date: NSDate)->Bool{
        let dateString = self.dateFormatter2.string(from: date as Date)
        var tt = CoreDataController.shared.caricaTuttiGliImpegni()
        for w in tt{
            if w.tipo?.uppercased() == "VERIFICA"{return true}
        }
        return false
    }
    
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        let dateString = self.dateFormatter2.string(from: date)
        let datesWithEvent = caricaDate()
        var count = 0
        for s in datesWithEvent{
            if s == dateString{
                count += 1
            }
        }
        if datesWithEvent.contains(dateString) {
            if count > 1{
                return 2
            }else{
                return 1}
        }
        
        return 0
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let currentPageDate = calendar.selectedDate
        
        selectedDay = date
        isAgenda = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        let nameOfMonth = dateFormatter.string(from: currentPageDate!)
        self.navigationItem.title = nameOfMonth.capitalizingFirstLetter()
        ImpPerGiornata.removeAll()
        
        SetDayImp(day: date)
        isAgenda = false
        
        print("data selezionata: \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("date: \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func AddTapped(at index: IndexPath) {
        print("\n\n\n\n\ntapped Completato\n\n\n\n\n")
    }
    
    func AddEvent(at index: IndexPath) {
        newEventInDayTransition = selectedDay
        IsDate = true
        performSegue(withIdentifier: "newEventFromCal", sender: nil)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.navigationItem.title = getMonth().capitalizingFirstLetter()
        
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
        
        
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func addEventInDayAction(_ sender: Any) {
        newEventInDayTransition = selectedDay
        IsDate = true
        performSegue(withIdentifier: "newEventFromCal", sender: nil)
    }
    
    @IBOutlet weak var loadingAg: UIView!
    
    @IBOutlet weak var noDatDesc: UITextView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ImpPerGiornata.count == 0 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateFormat = "EEEE dd MMMM yyyy"
            let today = Date()
            let conf = formatter.string(from: today).capitalizingFirstLetter()
            let risultato = formatter.string(from: selectedDay).capitalizingFirstLetter()
            if isAgenda{
                if eventiAgenda.count == 0{
                    noDatDesc.text! = "Non ci sono eventi in agenda per questo giorno"
                    noEventsView.isHidden = false
                }else{
                    noEventsView.isHidden = true
                    return eventiAgenda.count + 1
                }
            }
            if isAgenda{
                noDatDesc.text! = "Non ci sono eventi in agenda per questo giorno"
            }else{
                noDatDesc.text! = "Non ci sono eventi personali per questo giorno"
            }
            if conf == risultato{
                dayInView.text! = "Oggi"
            }else{
                dayInView.text = risultato
            }
            noEventsView.isHidden = false
            return 1
        }else{
            
            if isAgenda{
                if eventiAgenda.count == 0{
                    noDatDesc.text! = "Non ci sono eventi in agenda per questo giorno"
                    noEventsView.isHidden = false
                }else{
                    noEventsView.isHidden = true
                }
                return eventiAgenda.count + 1
            }else{
                noEventsView.isHidden = true
                return ImpPerGiornata.count + 2
            }
        }
        
        
        return 0
    }
    
    var cellaDaEliminare : Int = 0
    
    func eliminaCell(action: UIAlertAction){
        //elimino impegno da Core data e ricarico la view
        let DeleteId = ImpPerGiornata[cellaDaEliminare].id!
        CoreDataController.shared.cancellaImpegno(id: DeleteId)
        SetDayImp(day: selectedDay)
        self.tableView.reloadData()
        self.calendar.reloadData()
    }
    
    func infos(action: UIAlertAction){
        materiaV = ImpPerGiornata[cellaDaEliminare].materia!
        tipoV = ImpPerGiornata[cellaDaEliminare].tipo!
        descrizioneV = ImpPerGiornata[cellaDaEliminare].descrizione!
        dataV = ImpPerGiornata[cellaDaEliminare].perData!
        idV = ImpPerGiornata[cellaDaEliminare].id!
        performSegue(withIdentifier: "selected2", sender: nil)
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
    
    func MoreTapped(at index: IndexPath) {
        
        //moreButton viene premuto, func ottenuta dal delegate della classe MoreButtonsDelegate
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        cellaDaEliminare = index.row - 1
        menu.addAction(UIAlertAction(title: "Informazioni", style: .default, handler: self.infos))
        menu.addAction(UIAlertAction(title: "Elimina", style: .destructive, handler: self.eliminaCell))
        menu.addAction(UIAlertAction(title: "Indietro", style: .cancel, handler: nil))
        
        if let presenter = menu.popoverPresentationController {
            
            let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
            presenter.sourceView = ib.ibadView
            
        }
        self.present(menu, animated: true, completion: nil)
    }
    
    func CompletatoTapped(at index: IndexPath){
        print("\n\n\n\n\ntapped Completato\n\n\n\n\n")
        //il pulsante per l'evento completato viene premuto, gestione di esso grafica e nel database
        if ImpPerGiornata[index.row-1].completato == true {
            update(id: ImpPerGiornata[index.row-1].id!, completato: false)
            
            let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
            ib.completatoButton.setImage(#imageLiteral(resourceName: "VnotSelected"), for: .normal)
            ib.completatoLabel.text! = ""
            
        }else{
            update(id: ImpPerGiornata[index.row-1].id!, completato: true)
            
            let ib = tableView.cellForRow(at: index) as! Cell2_SenzaData
            ib.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
            ib.completatoLabel.text! = "completato"
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = Bundle.main.loadNibNamed("ProgrammaOggiCell", owner: self, options: nil)?.first as! ProgrammaOggiCell
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "it_IT")
            formatter.dateFormat = "EEEE dd MMMM yyyy"
            
            if isAgenda{
                cell.segmented.selectedIndex = 1
            }
            
            let risultato = formatter.string(from: selectedDay)
            cell.upperViewSep.isHidden = true
            cell.dataDiOggi.text! = risultato.capitalizingFirstLetter()
            cell.today.text! = "Eventi del giorno:"
            cell.delegate = self
            cell.indexPath = indexPath
            cell.selectionStyle = .none
            return cell
        }else if isAgenda{
            
            let cell =  tableView.dequeueReusableCell(withIdentifier: "hg", for: indexPath) as! agCel
            let iq = indexPath.row - 1
            noEventsView.isHidden = true
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
            formatter.dateFormat = "hh:mm"
            let hourString2 = formatter.string(from: eventiAgenda[iq].finisce)
            formatter.dateFormat = "hh:mm"
            let hourString = formatter.string(from: eventiAgenda[iq].inizia)
            cell.orario.text! = "\(hourString)-\(hourString2)"
            
            cell.desc.text! = eventiAgenda[iq].descrizine
            cell.profe.text! = eventiAgenda[iq].autore.lowercased().capitalized
            return cell
        }else{
            if indexPath.row == ImpPerGiornata.count+1{
                let cell = Bundle.main.loadNibNamed("AddCell", owner: self, options: nil)?.first as! AddCell
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }else{
                let cell = Bundle.main.loadNibNamed("Cell2_SenzaData", owner: self, options: nil)?.first as! Cell2_SenzaData
                cell.materia.text! = ImpPerGiornata[indexPath.row-1].materia!.uppercased()
                cell.tipo.text! = ImpPerGiornata[indexPath.row-1].tipo!.uppercased()
                cell.descrizione.text! = ImpPerGiornata[indexPath.row-1].descrizione!
                cell.view.backgroundColor = colori[Int(ImpPerGiornata[indexPath.row-1].colore!)!]
                if ImpPerGiornata[indexPath.row-1].completato == true{
                    cell.completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
                    cell.completatoLabel.text! = "completato"
                }
                cell.indexPath = indexPath
                cell.selectionStyle = .none
                cell.delegate = self
                
                return cell
            }
        }
        
    }
    
    private func makeColor(r: Double, g: Double, b: Double)->UIColor{
        //funzione per creare velocemente colori con rgb
        var retCol = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1.0)
        return retCol
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row != ImpPerGiornata.count+1{
            //solo elementi cliccabili
            materiaV = ImpPerGiornata[indexPath.row-1].materia!
            tipoV = ImpPerGiornata[indexPath.row-1].tipo!
            descrizioneV = ImpPerGiornata[indexPath.row-1].descrizione!
            dataV = ImpPerGiornata[indexPath.row-1].perData!
            idV = ImpPerGiornata[indexPath.row-1].id!
            performSegue(withIdentifier: "toDescNew", sender: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.row == 0{
            return 137.0
        }else{
            if isAgenda{
                tableView.estimatedRowHeight = 120
                return UITableView.automaticDimension
            }
            if indexPath.row == ImpPerGiornata.count+1{
                //return 61.0
                tableView.estimatedRowHeight = 61
                return UITableView.automaticDimension
            }else{
                //return 143.0
                tableView.estimatedRowHeight = 143
                return UITableView.automaticDimension
            }
        }
        
        
    }
    
    // MARK:- Target actions
    
    @IBAction func toggleClicked(sender: AnyObject) {
        
    }
    
    @IBOutlet weak var noViewCRR: UIView!
    
    
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
                            //self.voti.removeAll()
                            //self.tableView.reloadData()
                            self.noViewCRR.isHidden = false
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
        let risultato = formatter.string(from: selectedDay)
        
        var dateComponent = DateComponents()
        dateComponent.day = 1
        let sec = selectedDay.dayAfter
        let frt = formatter.string(from: sec)
        
        let url2 = URL(string: "https://web.spaggiari.eu/rest/v1/students/\(idinurl)/agenda/all/\(risultato)/\(frt)")!
        
        //"https://web17.spaggiari.eu/rest/v1/students/\(idinurl)/agenda/all/\(risultato)/\(risultato)"
        
        var request2 = URLRequest(url: url2)
        request2.httpMethod = "GET"
        
        request2.addValue("+zorro+", forHTTPHeaderField: "Z-Dev-ApiKey")
        request2.addValue("zorro/1.0", forHTTPHeaderField: "User-Agent")
        request2.addValue(token, forHTTPHeaderField: "Z-Auth-Token")
        eventiAgenda.removeAll()
        let task2 = URLSession.shared.dataTask(with: request2) { data, response, error in
            print(response)
            print(String(data: data!, encoding: .utf8))
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
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour], from: date)
                        let cmnts2 = calendar.dateComponents([.hour], from: dat2)
                        let initDate = calendar.date(from:components)
                        let finD = calendar.date(from:cmnts2)
                        
                        
                        var newAgenda  = eventoAgenda(id: b, code: evtCode[f], inizia: initDate!, finisce: finD!, isFullDay: fullDay[f], descrizine: notes[f], autore: autore[f], classDesc: classDesc[f], materia: materia[f])
                        self.eventiAgenda.append(newAgenda)
                        f += 1
                    }
                    
                    self.eventiAgenda = self.eventiAgenda.sorted(by: { $0.inizia.compare($1.inizia) == .orderedAscending })
                    print(self.eventiAgenda)
                    DispatchQueue.main.async {
                        self.isAgenda = true
                        self.loadingAg.isHidden = true
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
    
}



