//
//  materSettingsVC.swift
//  myDiario
//
//  Created by Enrico on 30/10/2019.
//  Copyright © 2019 Enrico Alberti. All rights reserved.
//

import UIKit

class materSettingsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

}

extension materSettingsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "genCel")
        cell.textLabel?.text = "-"
        return cell
    }
    
    
}
