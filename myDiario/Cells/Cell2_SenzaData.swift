//
//  Cell2_SenzaData.swift
//  AppStudente
//
//  Created by Enrico Alberti on 03/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit

class Cell2_SenzaData: UITableViewCell {
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var descrizione: UILabel!
    @IBOutlet weak var ibadView: UIView!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var completatoLabel: UILabel!
    
    @IBOutlet weak var completatoButton: UIButton!
    var delegate: MoreButtonsDelegate!
    @IBOutlet weak var moreButton: UIButton!
    var indexPath: IndexPath!
    
    
    @IBAction func moreAction(_ sender: UIButton) {
        self.delegate?.MoreTapped(at: indexPath)
    }
    
    
    @IBAction func completatoAction(_ sender: Any) {
        self.delegate?.CompletatoTapped(at: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 2
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var model: bubblyModel!{
        didSet{
            materia.text! = model.materia
            tipo.text! = model.tipo
            descrizione.text! = model.descrizione
        }
    }
    
}
