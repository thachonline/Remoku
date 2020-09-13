//
//  SettingsViewController.swift
//  Remote
//
//  Created by Jack Weber on 9/6/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var rokuIdTextView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateRokuID()
        NotificationCenter.default.addObserver(self, selector: #selector(updateRokuID), name: NSNotification.Name(rawValue: "ROKUFOUND"), object: nil)
        tableView.tableFooterView = UIView()
    }
    
    @objc func updateRokuID() {
        if let roku = RokuResolver.getRoku() {
            let ip = roku.split(separator: "/")[1].split(separator: ":")[0]
            rokuIdTextView.text = "Paired with Roku at \(ip)"
        } else {
            rokuIdTextView.text = "Not paired with a roku"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            performSegue(withIdentifier: "SettingsResolverSegue", sender: nil)
            break
        default:
            break
        }
    }
}
