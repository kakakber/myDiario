//
//  AddCell.swift
//  AppStudente
//
//  Created by Enrico Alberti on 30/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit

protocol addButtonProtocol{
    func AddEvent(at index: IndexPath)
}

class AddCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    
    var index: IndexPath = []
    
    @IBOutlet weak var backView: UIView!
    
    var delegate : addButtonProtocol!
    
    @IBAction func AddButtonPressed(_ sender: Any) {
        self.delegate?.AddEvent(at: index)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.clipsToBounds = false
        backView.layer.shadowColor = UIColor.lightGray.cgColor
        backView.layer.shadowOpacity = 0.4
        backView.layer.shadowOffset = CGSize.zero
        backView.layer.shadowRadius = 2
        backView.layer.shadowPath = UIBezierPath(roundedRect: backView.bounds, cornerRadius: addButton.frame.width/2).cgPath
        
        backView.addSubview(addButton)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
