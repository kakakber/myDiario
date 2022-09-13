//
//  NewCalendarVC.swift
//  myDiario
//
//  Created by Enrico on 10/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit
import FSCalendar
import ChameleonFramework
import DZNEmptyDataSet

class NewCalendarVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate{
         
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var todayLab: UILabel!
    
    var impegni : [Impegno] = []
    var impegniDiGiornata : [Impegno] = []
    
    var selectedDay : Date = Date()
    @IBAction func ext(_ sender: Any) {
        //navigationController?.setNavigationBarHidden(true, animated: false)
        performSegue(withIdentifier: "newFromCal", sender: nil)
    }
    
    @IBAction func selectedBullet(_ sender: Any) {
        performSegue(withIdentifier: "toBullet", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "calToOr" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! OrarioScolVC
            print("cuurent cal seg \(calendar.selectedDate!)")
            targetController.initialHour = calendar.selectedDate!
            return
        }
        
        if segue.identifier == "fromCalendarToEvt"{
            let targetController = segue.destination as! SelectedRowFinal
            if let indexPath = tableView.indexPathForSelectedRow{
                targetController.eventoScelto = EventoDiario(id: impegniDiGiornata[indexPath.row].id!, tipo: impegniDiGiornata[indexPath.row].tipo!, data: impegniDiGiornata[indexPath.row].perData!, descrizione: impegniDiGiornata[indexPath.row].descrizione!, materia: impegniDiGiornata[indexPath.row].materia!)
            }
            return
        }
        if segue.identifier == "toBullet"{
           let targetController = segue.destination as! bulletForDayVC
            print("seguing from \(selectedDateInCalendar)")
            targetController.date = selectedDateInCalendar
            return
        }
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController as! NewEventoGroupedVC
        targetController.isFromCalendar = true
        targetController.eventualDate = calendar.selectedDate!
    }
    
    
    var skeleton = true
    override func viewDidLoad(){
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        setUIUp()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(back), name: Notification.Name("GettingBackImm"), object: nil)
    }
        
    @objc func back(_ notification:Notification) {
        // Do something now
        print("back")
        
        impegni = CoreDataController.shared.caricaTuttiGliImpegni()
        fillImpegniDiGiornata(selectedDateInCalendar)
        //self.calendar.reloadData()
        //self.calendar.select(selectedDateInCalendar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        skeleton = UserDefaults.standard.bool(forKey: "skeleton") ?? true
        impegni = CoreDataController.shared.caricaTuttiGliImpegni()
        fillImpegniDiGiornata(selectedDateInCalendar)
        self.calendar.select(selectedDateInCalendar)
        self.calendar.reloadData()
    }
    
    deinit {
        print("\(#function)")
    }
    
    @IBAction func getOrario(_ sender: Any) {
        performSegue(withIdentifier: "calToOr", sender: nil)
    }
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        
        self.navigationItem.title = self.getMonth().capitalizingFirstLetter()
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
        }()
    
}
//MARK: Various funcs
extension NewCalendarVC{
    
    func getMonth() -> String{
        let currentPageDate = calendar.currentPage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let nameOfMonth = dateFormatter.string(from: currentPageDate)
        
        return nameOfMonth
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
    func fillImpegniDiGiornata(_ dat: Date){
        impegniDiGiornata.removeAll()
        impegniDiGiornata = impegniPerGiorno(dat)
        print("imp giornata: \(impegniDiGiornata.count)")
        tableView.reloadData()
    }
    
    func impegniPerGiorno(_ date: Date)->[Impegno]{
        var localImp = [Impegno]()
        let dt = dateFromString(format: "EEEE dd MMMM yyyy", date: formatDate(format: "EEEE dd MMMM yyyy", date: date))
        for x in impegni{
            if dt == dateFromString(format: "EEEE dd MMMM yyyy", date: x.perData!){
                localImp.append(x)
            }
        }
        return localImp
    }

}


//MARK: -SetUp
extension NewCalendarVC{
    func setUIUp(){
        todayLab.text! = "Oggi"
        setButtonNavBar()
        self.tabBarController?.tabBar.isHidden = false
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        
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
}

//MARK:- Table view
extension NewCalendarVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return impegniDiGiornata.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if skeleton{
            let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCell") as! skeletonCell
            cell.model = skeletonModel(impegniDiGiornata[indexPath.row])
            cell.viewColor.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
            return cell
        }
        /*let cell = Bundle.main.loadNibNamed("Cell2_SenzaData", owner: self, options: nil)?.first as! Cell2_SenzaData
        cell.model = bubblyModel(impegniDiGiornata[indexPath.row])
        cell.view.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
        //cell.delegate = self
        cell.indexPath = indexPath
        return cell*/
        let cell = tableView.dequeueReusableCell(withIdentifier: "bubblyCell") as! bubblyCell
        cell.model = skeletonModel(impegniDiGiornata[indexPath.row])
        cell.viewColor.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataController.shared.cancellaImpegno(id: impegniDiGiornata[indexPath.row].id!)
            impegniDiGiornata.removeAll()
            impegni = CoreDataController.shared.caricaTuttiGliImpegni()
            fillImpegniDiGiornata(selectedDateInCalendar)
            self.calendar.select(selectedDateInCalendar)
            self.calendar.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* if indexPath.row > 0 && indexPath.row != ImpPerGiornata.count+1{
         //solo elementi cliccabili
         materiaV = ImpPerGiornata[indexPath.row-1].materia!
         tipoV = ImpPerGiornata[indexPath.row-1].tipo!
         descrizioneV = ImpPerGiornata[indexPath.row-1].descrizione!
         dataV = ImpPerGiornata[indexPath.row-1].perData!
         idV = ImpPerGiornata[indexPath.row-1].id!
         performSegue(withIdentifier: "toDescNew", sender: nil)
         }
         */
        performSegue(withIdentifier: "fromCalendarToEvt", sender: nil)
    }
    
    
}

extension NewCalendarVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "\nNessun impegno per questa giornata"
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


//MARK:- Calendar manage
extension NewCalendarVC{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let iy = impegniPerGiorno(date)
        
        return iy.count
    }
    
    
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        fillImpegniDiGiornata(date)
        todayLab.text! = getDateOutput(date: date, format: "EEEE dd MMMM").capitalizingFirstLetter()
        selectedDateInCalendar = date
        self.navigationItem.title = formatDate(format: "MMMM", date: calendar.selectedDate!).capitalizingFirstLetter()
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.navigationItem.title = getMonth().capitalizingFirstLetter()
        
        //print("\(self.dateFormatter.string(from: calendar.currentPage))")
        
        
    }
}
//MARK: - UI/Animations
extension NewCalendarVC{
    private func makeColor(r: Double, g: Double, b: Double)->UIColor{
        //funzione per creare velocemente colori con rgb
        var retCol = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1.0)
        return retCol
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
    func rotateBarButton() {
        var jeff = 0
        if jeff % 2 == 0{
            self.barButton.customView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }else{
            self.barButton.customView?.transform = CGAffineTransform(rotationAngle: 0)
        }
        jeff += 1
    }
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
}
extension NewCalendarVC{
    override func viewDidAppear(_ animated: Bool) {
        self.calendar.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        colorz = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
    }
    func getColor(from: UIColor, to: UIColor)->UIColor{
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }
    
}
 /*
    
    
    var impegni : [Impegno] = []
    var impegniDiGiornata : [Impegno] = []
    var selectedDay : Date = Date()
    
    func setUp(){
        impegni = CoreDataController.shared.caricaTuttiGliImpegni()
        impegniPerGiorno(Date())
        self.calendar.select(Date())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonNavBar()
        UIApplication.shared.applicationIconBadgeNumber = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        // Do any additional setup after loading the view.
        
        setUp()
        self.tabBarController?.tabBar.isHidden = false
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
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
    [unowned self] in
        self.navigationItem.title = self.getMonth().capitalizingFirstLetter()
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    func getMonth() -> String{
        let currentPageDate = calendar.currentPage
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let nameOfMonth = dateFormatter.string(from: currentPageDate)
        
        return nameOfMonth
    }
    
    func impegniPerGiorno(_ dat: Date){
        impegniDiGiornata.removeAll()
        for x in impegni{
            if dat == dateFromString(format: "EEEE dd MMMM yyyy", date: x.perData!){
                impegniDiGiornata.append(x)
                print(x)
            }
        }
    }

}

extension NewCalendarVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return impegniDiGiornata.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if skeleton{
                return UITableView.automaticDimension
            }
            if indexPath.row > 0 && impegniDiGiornata[indexPath.row].perData! == impegniDiGiornata[indexPath.row-1].perData!{
                return 142
            }
        return 191
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if skeleton{
                   if indexPath.row > 0 && impegniDiGiornata[indexPath.row].perData! == impegniDiGiornata[indexPath.row-1].perData!{
                       let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCell") as! skeletonCell
                       cell.model = skeletonModel(impegniDiGiornata[indexPath.row])
                       cell.viewColor.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
                       return cell
                   }else{
                       let cell = tableView.dequeueReusableCell(withIdentifier: "skeletonCellWithDate") as! skeletonCellWithDate
                       cell.model = skeletonModel(impegniDiGiornata[indexPath.row])
                       cell.viewColor.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
                       return cell
                   }
               }
               
               if indexPath.row > 0 && impegniDiGiornata[indexPath.row].perData! == impegniDiGiornata[indexPath.row-1].perData!{
                   let cell = Bundle.main.loadNibNamed("Cell2_SenzaData", owner: self, options: nil)?.first as! Cell2_SenzaData
                   cell.model = bubblyModel(impegniDiGiornata[indexPath.row])
                   cell.view.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
                   cell.delegate = self
                   cell.indexPath = indexPath
                   return cell
               }
               let cell = Bundle.main.loadNibNamed("Cell1_ConData", owner: self, options: nil)?.first as! Cell1_ConData
               cell.model = bubblyModel(impegniDiGiornata[indexPath.row])
               cell.view.layer.backgroundColor = colorz[Int(impegniDiGiornata[indexPath.row].colore!)!].cgColor
               cell.indexPath = indexPath
               cell.delegate = self
               return cell
    }
    
    
}

extension NewCalendarVC: FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate{
    func setButtonNavBar(){
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Create new button & set its frame
        button.setImage(UIImage(named: "down-arrow"), for: .normal) // Assign an image
        button.addTarget(self, action: #selector(ButtonAction), for: .touchUpInside)
        
        barButton.customView = button // Set as barButton's customView
        
    }
    @objc func ButtonAction(sender: UIButton){
        //self.rotateBarButton()
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
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
        
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MMMM"
           
           let nameOfMonth = dateFormatter.string(from: currentPageDate!)
           self.navigationItem.title = nameOfMonth.capitalizingFirstLetter()
        impegniDiGiornata.removeAll()
           
           impegniPerGiorno(date)
           
           print("data selezionata: \(formatDate(format: "yyyy/MM/dd", date: date))")
        
           let selectedDates = calendar.selectedDates.map({formatDate(format: "yyyy/MM/dd", date: $0)})
        
           print("date: \(selectedDates)")
           if monthPosition == .next || monthPosition == .previous {
               calendar.setCurrentPage(date, animated: true)
           }
       }
}
extension NewCalendarVC: MoreButtonsDelegate{
    func MoreTapped(at index: IndexPath) {
        //
    }
    
    func CompletatoTapped(at index: IndexPath) {
        //
    }
    
    func firstSel(at index: IndexPath) {
        //
    }
    
    func seconSel(at index: IndexPath) {
        //
    }
    
    
}

extension NewCalendarVC{
    override func viewWillAppear(_ animated: Bool) {
        self.calendar.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        colorz = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
    }
    func getColor(from: UIColor, to: UIColor)->UIColor{
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }
}*/

