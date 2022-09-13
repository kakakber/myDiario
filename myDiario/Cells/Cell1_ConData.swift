//
//  Cell1_ConData.swift
//  AppStudente
//
//  Created by Enrico Alberti on 02/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit

protocol MoreButtonsDelegate{
    func MoreTapped(at index:IndexPath)
    func CompletatoTapped(at index:IndexPath)
    func firstSel(at index:IndexPath)
    func seconSel(at index:IndexPath)
}


class Cell1_ConData: UITableViewCell {
    
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var tipo: UILabel!
    
    @IBOutlet weak var ipadSelectView: UIView!
    
    var delegate: MoreButtonsDelegate!
    
    @IBOutlet weak var completatoLabel: UILabel!
    
    @IBOutlet weak var completatoButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var indexPath: IndexPath!
    
    @IBAction func moreButtonAction(_ sender: UIButton) {
        self.delegate?.MoreTapped(at: indexPath)
    }
    
    @IBAction func completatoButtonAction(_ sender: Any) {
        self.delegate?.CompletatoTapped(at: indexPath)
    }
    
    var isDone = true
    
    @IBOutlet weak var descrizione: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 5
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var model: bubblyModel!{
        didSet{
            data.text! = model.data
            materia.text! = model.materia
            tipo.text! = model.tipo
            descrizione.text! = model.descrizione
            isDone = model.done
            if isDone{
                completatoButton.setImage(#imageLiteral(resourceName: "vend"), for: .normal)
            }else{
                completatoButton.setImage(#imageLiteral(resourceName: "VnotSelected"), for: .normal)
            }
        }
    }
    
}
