//
//  ProgrammaOggiCell.swift
//  AppStudente
//
//  Created by Enrico Alberti on 04/12/17.
//  Copyright © 2017 Enrico Alberti. All rights reserved.
//

import UIKit

class ProgrammaOggiCell: UITableViewCell {
    
    
    @IBOutlet weak var dataDiOggi: UILabel!
    
    @IBOutlet weak var segmented: HBSegmentedControl!
    
    var delegate: MoreButtonsDelegate!
    
    @IBOutlet weak var upperViewSep: UIView!
    
    @IBOutlet weak var today: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        segmented.items = ["Personali", "Registro"]
        segmented.selectedLabelColor = .white
        segmented.unselectedLabelColor = .black
        segmented.backgroundColor = UIColor.flatWhite()
        segmented.thumbColor = .black
        segmented.selectedIndex = 0
        segmented.font = UIFont(name: "Avenir-Black", size: 12)
        segmented.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmented.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
    }
    
    var indexPath: IndexPath!
    
    @objc func segmentValueChanged(_ sender: AnyObject?){
        
        if segmented.selectedIndex == 0 {
            print("a")
            self.delegate?.firstSel(at: indexPath)
        }else if segmented.selectedIndex == 1{
            print("b")
            self.delegate?.seconSel(at: indexPath)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
