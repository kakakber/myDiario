//
//  Images_descriptionsVCViewController.swift
//  AppStudente
//
//  Created by Enrico Alberti on 12/01/18.
//  Copyright © 2018 Enrico Alberti. All rights reserved.
//

import UIKit
//import INSPhotoGallery
import JGProgressHUD

var isTrashing = false

protocol DeleteTheImage{
    func Delete(at index:IndexPath)
}

class Images_descriptionsVCViewController:UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UIPopoverControllerDelegate, DeleteTheImage, UITextFieldDelegate{
    func Delete(at index: IndexPath) {
        print("delete")
    }
    
    
    /*
    @IBOutlet weak var SelectedImgView: UIView!
    @IBOutlet weak var descrizioneA: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var useCustomOverlay = false
    let controller = UIImagePickerController()
    
    @IBOutlet weak var delete: UIButton!
    var addingImage = UIImage()
    var immagini: [UIImage] = []
    var descriz: [String] = []
    
    @IBOutlet weak var imgSel: UIImageView!
    @IBOutlet weak var noImgsView: UIView!
    
    let hud = JGProgressHUD(style: .light)
    
    lazy var photos: [INSPhotoViewable] = {
        return [
        
        ]
    }()
    var immaginiAct : [Immagini] = []
    
    @IBAction func trash(_ sender: Any) {
        if isTrashing{
            isTrashing = false
        }else{
          isTrashing = true
        }
        collectionView.reloadData()
    }
    
    func AllImagesForSubj(){
        immaginiAct = CoreDataController.shared.ImmaginiPerMateria(materia: materiaV)
        
        if immaginiAct.isEmpty{
            noImgsView.isHidden = false
            isTrashing = false
        }else{
            noImgsView.isHidden = true
        }
    
        immaginiAct = immaginiAct.reversed()//reversed per far veder prima i più recenti
        
        for x in immaginiAct{
            let dataDecoded : Data = Data(base64Encoded: x.image!, options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            
            immagini.append(decodedimage!)
        }
        
    }
    
    func Delete(at index: IndexPath) {
        print("button premuto a \(index.row)")
        CoreDataController.shared.cancellaImmagine(id: immaginiAct[index.row].idOfImage!)
        immagini.removeAll()
        photos.removeAll()
        
        didLoadFunc()
        collectionView.reloadData()
    }
    
    func didLoadFunc(){
         AllImagesForSubj()
        for s in immagini{
            photos.append(INSPhoto(image: s, thumbnailImage: s))
        }
        var iter = 0;
        for photo in photos {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE dd MMMM yyyy"
            
            var datess = immaginiAct[iter].data!
            if let date = dateFormatter.date(from: immaginiAct[iter].data!){
                dateFormatter.locale = Locale(identifier: "it_IT")
                dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM/yy")
                datess = (dateFormatter.string(from: date))
            }
            var desc = immaginiAct[iter].descrizione!
            if immaginiAct[iter].descrizione! == ""{
                desc = "Nessuna descrizione"
            }
            if let photo = photo as? INSPhoto {
                photo.attributedTitle = NSAttributedString(string: "\(datess): \(desc )", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
                
            }; iter += 1;
        }
        hud?.dismiss()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isTrashing = false
        addToolBar(textField: descrizioneA)
        descrizioneA.delegate = self
        didLoadFunc()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBOutlet weak var modifyImageView: UIView!
    
    @IBAction func modifyImageButton(_ sender: Any) {
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        menu.addAction(UIAlertAction(title: "Scegli dal rullino foto", style: .default, handler: self.imagePick))
        
        menu.addAction(UIAlertAction(title: "Scatta foto", style: .default, handler: self.cameraSelect))
     
        menu.addAction(UIAlertAction(title: "Indietro", style: .cancel, handler: nil))
        
        if let presenter = menu.popoverPresentationController {
            presenter.sourceView = modifyImageView
            
        }
        
        self.present(menu, animated: true, completion: nil)
    }
    
    
    
    func cameraSelect(action: UIAlertAction){
        //scattare foto profilo
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.delegate = self
            controller.allowsEditing = false
            controller.sourceType = UIImagePickerControllerSourceType.camera
            controller.cameraCaptureMode = .photo
            controller.modalPresentationStyle = .fullScreen
            
            present(controller,animated: true,completion: nil)
        } else {
            noCamera()
        }
        
    }
    
    func imagePick(action: UIAlertAction){
        //scegliere immagine da rullino
        
        controller.delegate = self
        controller.allowsEditing = false
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
        
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
    
    let size = CGSize(width: 500, height: 500)
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //quando si ha scelto immagine la cambia l'immagine profilo in display
        dismiss(animated: true, completion: nil)
        let immagineSelezionata = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        addingImage = immagineSelezionata
        imgSel.image = addingImage
        SelectedImgView.isHidden = false
    }
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Fine", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    @objc func donePressed(){
        descrizioneA.resignFirstResponder()
    }
  
    @IBAction func annulla(_ sender: Any) {
        SelectedImgView.isHidden = true
    }
    
    @IBAction func altraImmagine(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBOutlet weak var animater: UIActivityIndicatorView!
    
    @IBAction func continua(_ sender: Any) {
        
        let image : UIImage = addingImage
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        let newIdImg = UUID().uuidString
        var desc = ""
        if descrizioneA.text! != ""{
            desc = descrizioneA.text!
        }
        
        CoreDataController.shared.newImage(forImpegnoId: idV, forMateria: materiaV, ImageString: strBase64, ImageID: newIdImg, data: dataV, descrizione: desc)
        
        immagini.removeAll()
        photos.removeAll()
        
        didLoadFunc()
        SelectedImgView.isHidden = true
        collectionView.reloadData()
    }
    
    
}
protocol DeleteTheImage{
    func Delete(at index:IndexPath)
}

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var delBut: UIButton!
    
    var delegate: DeleteTheImage!
    
    var index : IndexPath!
    
    @IBAction func deletaAct(_ sender: Any) {
        self.delegate.Delete(at: index)
    }
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.thumbnailImage = image
                }
                self.imageView.image = image
            }
        }
    }
}


extension Images_descriptionsVCViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        cell.index = indexPath
        cell.delegate = self
        
        if isTrashing{
            cell.delBut.isHidden = false
        }else{
            cell.delBut.isHidden = true
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.index(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = 0
        if self.collectionView.numberOfItems(inSection: 0) > 2{
            width = Int(collectionView.frame.width / 3 - 5)
        }else{
            width = Int(collectionView.frame.width / 2 - 6)}
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }*/
    
    override func viewDidLoad() {
        
    }
}
