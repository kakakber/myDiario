//
//  NewRowSelected_VC.swift
//  AppMascheroni
//
//  Created by Enrico Alberti on 06/12/2018.
//  Copyright © 2018 Enrico Alberti. All rights reserved.
//
/*
import UIKit

//immagini della materia

fileprivate func getImageForMateria(materia: String) -> [UIImage]{
    
    var immaginiAct = [Immagini]()
    var immagini = [UIImage]()
    immaginiAct = CoreDataController.shared.ImmaginiPerMateria(materia: materia)
    
    immaginiAct = immaginiAct.reversed()//reversed per far veder prima i più recenti
    
    for x in immaginiAct{//da string in CorreData a UIImage con base64 decoding
        let dataDecoded : Data = Data(base64Encoded: x.image!, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        
        immagini.append(decodedimage!)
    }
    
    
    return immagini
    
}


enum tipiDiAggiornamentoEventoDiario{
    case tipo
    case data
    case descrizione
}

/*class newRowSelectedDataSource : NSObject, UITableViewDataSource{
    // MARK: - Table View
    
}*/
//questo l'avrei fatto con una table view complessa e da riutilizzare

protocol newRowCellUpdateDelegate{
    func updateCell()
}

class newRowCell : UITableViewCell, UITextViewDelegate{
    @IBOutlet weak var descrizione: UITextView!
    
    var delegateForH : newRowCellUpdateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descrizione.delegate = self
        addToolBar2(textField: descrizione)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        eventoScelto.descrizione = descrizione.text!
        delegateForH?.updateCell()
    }
    
    @objc func donePressed(){
        eventoScelto.descrizione = descrizione.text!
        eventoScelto.update(type: .descrizione, id: eventoScelto.id, testoDiUpdate: descrizione.text!)
        
        descrizione.resignFirstResponder()
    }
    
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
}

class newMediaCell : UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource{
    override func awakeFromNib() {
        gtim()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
  
    //DispatchQueue.main.async(execute: { () -> Void in
    
    //tableView.reloadData()
    // })
    
    var immaginiz = [UIImage]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    func gtim(){
        
            var immaginiAct = [Immagini]()
            
            immaginiAct = CoreDataController.shared.ImmaginiPerMateria(materia: materiaV)
            
            immaginiAct = immaginiAct.reversed()//reversed per far veder prima i più recenti
            
            for x in immaginiAct{//da string in CorreData a UIImage con base64 decoding
                let dataDecoded : Data = Data(base64Encoded: x.image!, options: .ignoreUnknownCharacters)!
                let decodedimage = UIImage(data: dataDecoded)
                DispatchQueue.main.async {
                    self.immaginiz.append(decodedimage!)
                }
            }
            
            DispatchQueue.main.async {
                print("got imgs");
                self.collectionView.reloadData()
            }
            //})
    }
    //DispatchQueue.main.async(execute: { () -> Void in
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return immaginiz.count + 1

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collnewrowsel", for: indexPath) as! newRowCollCell
        cell.indexPath = indexPath
        cell.delegated = self
        if immaginiz.count == 0{
        cell.immagine.image = UIImage(named: "newMedia")
        }else{
            if indexPath.row != immaginiz.count{
                cell.immagine.image = immaginiz[indexPath.row]
            }else{
                cell.immagine.image = UIImage(named: "newMedia")
            }
            cell.immagine.layer.cornerRadius = 8
            cell.immagine.clipsToBounds = true
            }
        return cell
    }
    
    var immagini = [UIImage]()
}

fileprivate var SelNewImg = false

extension newMediaCell: pressedImageDelegate{
    //immagine premuta
    func ImageButtonPressed(at index: IndexPath) {
        print("pressed inside cell --")
        selectedImageIndex = index.row
        if selectedImageIndex == immaginiz.count{
            SelNewImg = true
        }else{
            SelNewImg = false
        }
        let notification = NSNotification(name:NSNotification.Name(rawValue: "imageSelected"), object: nil, userInfo: nil)
        NotificationCenter.default.post(notification as Notification)
    }
}

fileprivate var selectedImageIndex = Int()

protocol pressedImageDelegate{
    func ImageButtonPressed(at index : IndexPath)
}

class newRowCollCell : UICollectionViewCell{
    @IBOutlet weak var immagine: UIImageView!
    var delegated : pressedImageDelegate!
    var indexPath : IndexPath!
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.delegated.ImageButtonPressed(at: indexPath)
    }
    
}

var eventoScelto = EventoDiario()

class NewRowSelected_VC: UIViewController{
    
    //nuova immagineDaAggiungere
    
    private var newImgS = UIImage(named: "picture")
    
    @IBOutlet weak var tipoText: UITextField!
    
    //assegno con un prepare for segue
    @IBOutlet weak var tableView: UITableView!
    
    let controller = UIImagePickerController()
    
    var allImagesForEvent = [UIImage]()
    
    override func viewWillDisappear(_ animated: Bool) {
        eventoScelto.update(type: .descrizione, id: idV, testoDiUpdate: eventoScelto.descrizione)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initFunc()
        eventoScelto = EventoDiario()
        
        addToolBar(textField: tipoText)
        
        title = materiaV.uppercased()
        
        tipoText.delegate = self
        tipoText.text! = eventoScelto.tipo
        
        //tableView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        
        tableView.estimatedRowHeight = 76
        tableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
        
        tipoText.addTarget(self, action: #selector(NewRowSelected_VC.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(imageSelected(_:)), name: Notification.Name(rawValue: "imageSelected"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(loadedImgs(_:)), name: Notification.Name(rawValue: "imagesDone"), object: nil)
    }
    
    
    /*@objc func loadedImgs(_ notification:Notification){
        tableView.reloadData()
    }*/
    
}


extension NewRowSelected_VC : newRowCellUpdateDelegate{//quando scrivo aggiorna cell quindi cambia dimensioni della UIView
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

extension NewRowSelected_VC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return 129
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mediPlus") as! newMediaCell
            cell.immagini = allImagesForEvent
            return cell
        default:
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "newRowSelCell") as! newRowCell
            
            cell.descrizione.text! = eventoScelto.descrizione
            cell.delegateForH = self
            return cell
        }
    }
}


extension NewRowSelected_VC : UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        eventoScelto.update(type: .tipo, id: idV, testoDiUpdate: tipoText.text!)
    }
    
    @objc func donePressed(){
        tipoText.resignFirstResponder()
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
}

extension NewRowSelected_VC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @objc func imageSelected(_ notification:Notification){
        print("selezionataFunc in main")
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        menu.addAction(UIAlertAction(title: "Scegli dal rullino foto", style: .default, handler: self.imagePick))
        
        menu.addAction(UIAlertAction(title: "Scatta foto", style: .default, handler: self.cameraSelect))
        
        menu.addAction(UIAlertAction(title: "Indietro", style: .cancel, handler: nil))
        
        if let presenter = menu.popoverPresentationController {
            //presenter.sourceView = modifyImageView
            
        }
        if SelNewImg{
            self.present(menu, animated: true, completion: nil)
            
        }
    }
    
    func imagePick(action: UIAlertAction){
        //scegliere immagine da rullino
        
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
        
    }
    
    func cameraSelect(action: UIAlertAction){
        //scattare foto profilo
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.delegate = self
            controller.allowsEditing = false
            controller.sourceType = UIImagePickerController.SourceType.camera
            controller.cameraCaptureMode = .photo
            controller.modalPresentationStyle = .fullScreen
            
            present(controller,animated: true,completion: nil)
        } else {
            noCamera()
        }
        
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "Nessuna Camera",
            message: "Spiacente, a quanto pare questo device non dispone di una fotocamera funzionante",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //quando si annulla image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        let immagineSelezionata = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        newImgS = immagineSelezionata
        
        performSegue(withIdentifier: "toNew", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! newImgVC
        destVC.newImgINVC = newImgS!
    }
    
}

//VC to add new Image

class newImgVC : UIViewController{
    
    var newImgINVC = UIImage()
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var descrizione: UITextField!
    
    override func viewDidLoad() {
        title = "Aggiungi"
        image.image = newImgINVC
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        
        aggiungiOutlet.layer.cornerRadius = 9
    }
    
    @IBOutlet weak var aggiungiOutlet: UIButton!
    
    @IBAction func aggiungiAction(_ sender: Any) {
        let queue = DispatchQueue(label: "it.enrico.imgGot", qos: .userInitiated)
        queue.async {
            let image : UIImage = self.newImgINVC
            let imageData:NSData = image.pngData()! as NSData
            let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
            let newIdImg = UUID().uuidString
            var desc = String()
            if self.descrizione.text! != ""{
                desc = self.descrizione.text!
            }
            CoreDataController.shared.newImage(forImpegnoId: idV, forMateria: materiaV, ImageString: strBase64, ImageID: newIdImg, data: dataV, descrizione: desc)
            DispatchQueue.main.async {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
*/
