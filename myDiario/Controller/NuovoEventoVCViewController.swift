//
//  NuovoEventoVCViewController.swift
//  AppStudente
//
//  Created by Enrico Alberti on 02/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit
import CoreData
import JGProgressHUD
import DropDown
import UserNotifications
import ChameleonFramework

class NuovoEventoVCViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var materiaTextField: UITextField!
    @IBOutlet weak var collView: UICollectionView!
    
   
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descrizioneTextField: UITextField!
    @IBOutlet weak var perDataTextField: UITextField!
    @IBOutlet weak var tipoTextField: UITextField!
    @IBOutlet weak var viewMat: UIView!
    @IBOutlet weak var notificaLabel: UILabel!
    @IBOutlet weak var notificaPicker: UIDatePicker!
    @IBOutlet weak var viewForDropMateria: UIView!
    @IBOutlet weak var viewForDropTipo: UIView!
    
    @IBOutlet weak var dayButtonOutlet: UIButton!
    @IBOutlet weak var switchButton: UISwitch!
    
    @IBOutlet weak var materieListButton: UIButton!
    
    var colori : [UIColor] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        
        notificaLabel.text! = "\(hour):\(minute)"
        
        datePicker.isHidden = true;
        
        if IsDate{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
            let strDate = dateFormatter.string(from: newEventInDayTransition)
            self.perDataTextField.text! = strDate
            IsDate = false
        }else{
            //se non è una transizione da calendario inserisce come data predefinita la data corrente
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "it_IT")
            dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
            let strDate = dateFormatter.string(from: today)
            self.perDataTextField.text! = strDate
        }
        
        self.tabBarController?.tabBar.isHidden = true
       
        
        colori = [getColor(from: FlatNavyBlue(), to: FlatNavyBlueDark()), getColor(from: FlatSkyBlue(), to: FlatSkyBlueDark()), getColor(from: FlatRed(), to: FlatRedDark()), getColor(from: FlatYellow(), to: FlatYellowDark()), getColor(from: FlatOrange(), to: FlatOrangeDark()), getColor(from: FlatPurple(), to: FlatPurpleDark()), getColor(from: FlatPlum(), to: FlatPlumDark()), getColor(from: FlatPink(), to: FlatPinkDark()), getColor(from: FlatGray(), to: FlatGrayDark()), getColor(from: FlatGreen(), to: FlatGreenDark()), getColor(from: FlatForestGreen(), to: FlatForestGreenDark()), getColor(from: FlatMint(), to: FlatMintDark()), getColor(from: FlatCoffee(), to: FlatCoffeeDark()), getColor(from: FlatSand(), to: FlatSandDark())]
        
        notificaPicker.addTarget(self, action: #selector(NuovoEventoVCViewController.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        aggiungiButton.isHidden = true
        
        fineButtonDate.isHidden = true
        
        datePicker.backgroundColor = UIColor.white
        
        collView.delegate = self
        collView.dataSource = self
        
        addToolBar(textField: descrizioneTextField)
        addToolBar(textField: materiaTextField)
        addToolBar(textField: tipoTextField)
        
        materiaTextField.delegate = self
        descrizioneTextField.delegate = self
        perDataTextField.delegate = self
        
        var currentDate = Date()
        
//        datePicker.minimumDate = currentDate

        // Do any additional setup after loading the view.
    }
    
    var materie : [String] = ["matematica", "fisica", "italiano", "scienze", "inglese", "storia", "filosofia", "informatica", "arte", "latino"]
    
    @IBAction func scegliListMateriaAction(_ sender: Any) {
        dropDown.dataSource = materie
        dropDown.anchorView = viewForDropMateria
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.materiaTextField.text! = item
            if self.allTextPutFunc(){
                self.aggiungiButton.isHidden = false
            }else{
                self.aggiungiButton.isHidden = true
            }
        }
    
    }
    @IBAction func notificaAction(_ sender: Any) {
        if notificaPicker.isHidden{
            notificaPicker.isHidden = false
        }else{
            notificaPicker.isHidden = true
        }
    }
    
    
    @IBAction func notificaPickerAct(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.locale = Locale(identifier: "it_IT")
        let strDate = dateFormatter.string(from: datePicker.date)
        self.notificaLabel.text! = strDate
    }
    
    var dateZ = Date()
    
    @objc func datePickerValueChanged (datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "it_IT")
        let strDate = dateFormatter.string(from: datePicker.date)
        self.notificaLabel.text! = strDate
        dateZ = datePicker.date
    }
    var isNotif = false
    
    @IBAction func switchTapped(_ sender: Any) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
            if didAllow{
                self.isNotif = true
            }else{
                //se l'utente non ha le notifiche attivate
                self.errorAlert()
            }
        }
        
    }
    
    
    
    func errorAlert(){
        let alert = UIAlertController(title: "Notifiche disattivate", message: "Vai su: [Impostazioni > Notifiche > Mascheroni > Consenti notifiche] per usufruire della funzione", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action:UIAlertAction!) in
            self.switchButton.setOn(false, animated: true)
        }))
        
        self.present(alert, animated: true)
    }
    
    
    var tipi : [String] = ["compito", "verifica", "progetto"]
    
    @IBAction func scegliTipoDropAction(_ sender: Any) {
        dropDown.dataSource = tipi
        dropDown.anchorView = viewForDropTipo
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.tipoTextField.text! = item
            if self.allTextPutFunc(){
                self.aggiungiButton.isHidden = false
            }else{
                self.aggiungiButton.isHidden = true
            }
        }
    }
    
    func getColor(from: UIColor, to: UIColor)->UIColor{
       
        //i due coloti per gradiante
        let colors = [from, to]
        
        return GradientColor(gradientStyle: .leftToRight, frame: view.frame, colors: colors)
        
    }

    
    private func makeColor(r: Double, g: Double, b: Double)->UIColor{
        let retCol = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1.0)
        return retCol
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        // nascondi la tastiera
        textfield.resignFirstResponder()
        return true
    }
    
    var colorSelected : Int = 1
    
    @IBOutlet weak var fineButtonDate: UIButton!
    
    @IBAction func dataSelected(_ sender: Any) {
        materiaTextField.resignFirstResponder()
        descrizioneTextField.resignFirstResponder()
        perDataTextField.resignFirstResponder()
        tipoTextField.resignFirstResponder()
        
        datePicker.isHidden = false
        fineButtonDate.isHidden = false
    }

    @IBAction func fineActionDate(_ sender: Any) {
       datePicker.isHidden = true
        fineButtonDate.isHidden = true
        
        if allTextPutFunc(){
            aggiungiButton.isHidden = false
        }else{
            aggiungiButton.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colori.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ColorCollectionViewCell
        cell.ColorView?.layer.cornerRadius = 6
        cell.ColorView?.backgroundColor = colori[indexPath.row]
        cell.ColorView?.layer.cornerRadius = (cell.ColorView?.frame.size.width)!/2
        cell.ColorView?.clipsToBounds = true
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        colorSelected = indexPath.row
    }
    
    @IBAction func DatePicher_Action(_ sender: Any) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT")
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        self.perDataTextField.text! = strDate
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if allTextPutFunc(){
            aggiungiButton.isHidden = false
        }else{
            aggiungiButton.isHidden = true
        }
    }
    
    func allTextPutFunc() -> Bool{
        var retValue = false
        if materiaTextField.text! != "" &&  tipoTextField.text! != "" && perDataTextField.text! != ""{
            retValue = true
        }
        return retValue
    }
    
    @IBAction func AggiungiAct(_ sender: Any) {
        let uuid = UUID().uuidString
        var desc = ""; if descrizioneTextField.text! != ""{
            desc = descrizioneTextField.text!;
        }else{
            desc = "Nessuna descrizione"
        }
        CoreDataController.shared.newImpegno(materia: materiaTextField.text!, completato: false, tipo: tipoTextField.text!, descrizione: desc, perData: perDataTextField.text!, id: uuid, colore: "\(colorSelected)")
        
        if switchButton.isOn{
            //attiva notifica
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "it_IT")
            
            let calendar = Calendar.current
            
            let hour = calendar.component(.hour, from: self.dateZ)-2
            let minute = calendar.component(.minute, from: self.dateZ)
            
            
            let dat = (dateFormatter.date(from: self.perDataTextField.text!)!)
            let dates = dat.setTime(hour: hour, min: minute, sec: 0)
            
            self.setNot(date: (dates?.dayBefore)!, titolo: "\(self.tipoTextField.text!.capitalizingFirstLetter()) di \(self.materiaTextField.text!) per domani", contenuto: self.descrizioneTextField.text!.capitalizingFirstLetter())
            
        }
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
        
        hud.textLabel.text = "Evento aggiunto con successo"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.3, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 1.8, repeats: false) { (Timer) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
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
    @objc func donePressed(){
        materiaTextField.resignFirstResponder()
        descrizioneTextField.resignFirstResponder()
        perDataTextField.resignFirstResponder()
        tipoTextField.resignFirstResponder()
        datePicker.isHidden = true
        fineButtonDate.isHidden = true
    }
    
    
    
    func setNot(date: Date, titolo: String, contenuto: String){
        let notification = UNMutableNotificationContent()
        notification.title = titolo
        notification.body = contenuto
        notification.badge = 1
        
        // *** create calendar object ***
        var calendar = NSCalendar.current
        
        // *** Get components using current Local & Timezone ***
        print(calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date))
        
        // *** define calendar components to use as well Timezone to UTC ***
        let unitFlags = Set<Calendar.Component>([.hour, .year, .minute])
        calendar.timeZone = TimeZone.current
        
        // *** Get All components from date ***
        let components = calendar.dateComponents(unitFlags, from: date as Date)
        
        
       let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
     
       let request = UNNotificationRequest(identifier: "notification1", content: notification, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    @IBOutlet weak var aggiungiButton: UIButton!
    
}
