//
//  Row_SelectedVC.swift
//  AppStudente
//
//  Created by Enrico Alberti on 04/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//


import UIKit

/*
class Row_SelectedVC: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fineButton: UIButton!
    @IBOutlet weak var tipo: UITextField!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var descrizione: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fineButton.isHidden = true
        datePicker.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        title = materiaV
        title = title?.uppercased()
        tipo.text! = tipoV
        tipo.text = tipo.text?.uppercased()
        data.text! = dataV
        descrizione.text! = descrizioneV
        addToolBar(textField: descrizione)
        addToolBar2(textField: tipo)
        descrizione.delegate = self
        tipo.delegate = self
        datePicker.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        checkSize()
    }
    
    func checkSize(){
        if descrizione.contentSize.height > descrizione.frame.size.height {
            
            let fixedWidth = descrizione.frame.size.width
            descrizione.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            
            var newFrame = descrizione.frame
            let newSize = descrizione.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            
            
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            
            descrizione.frame = newFrame;
        }
    }
    
    @IBAction func selectDateButton(_ sender: Any) {
        fineButton.isHidden = false
        datePicker.isHidden = false
    }
    
    @IBAction func fin(_ sender: Any) {
        fineButton.isHidden = true
        datePicker.isHidden = true
    }
    
    @IBAction func datePicherAction(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "it_IT")
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
        let strDate = dateFormatter.string(from: datePicker.date)
        self.data.text! = strDate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateDescription(id: idV, updateText: descrizione.text!)
        updateType(id: idV, updateText: tipo.text!)
        updateDate(id: idV, updateText: data.text!)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkSize()
        updateDescription(id: idV, updateText: descrizione.text!)
        updateType(id: idV, updateText: tipo.text!)
        updateDate(id: idV, updateText: data.text!)
    }
    func updateType(id: String, updateText: String){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.tipo = updateText
        do{
            try impegno.managedObjectContext!.save()
        } catch{
            print("errore nella modifica dell'impegno (tipo)")
        }
    }
    
    func updateDate(id: String, updateText: String){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.perData = updateText
        do{
            try impegno.managedObjectContext!.save()
        } catch{
            print("errore nella modifica dell'impegno (data)")
        }
    }
    
    func updateDescription(id: String, updateText: String){
        let impegno = CoreDataController.shared.ImpegniPerId(Id: id)
        impegno.descrizione = updateText
        do{
            try impegno.managedObjectContext!.save()
        } catch{
            print("errore nella modifica dell'impegno (descrizione)")
        }
    }
    
    @objc func donePressed(){
        checkSize()
        descrizione.resignFirstResponder()
    }
    
    func addToolBar(textField: UITextView){
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
    
    func addToolBar2(textField: UITextField){
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}*/
