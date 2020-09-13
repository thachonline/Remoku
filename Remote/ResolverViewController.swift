//
//  ResolverViewController.swift
//  Remote
//
//  Created by Jack Weber on 8/28/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit
import SSDPClient

class ResolverViewController: UIViewController {
    
    var rokus = [String]()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        let discovery = ServiceDiscovery(delegate: self)
        discovery.start()
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: 10)
            if self.rokus.count == 0 {
                DispatchQueue.main.async {
                    self.indicator.isHidden = true
                    let alert = UIAlertController(title: "Could not find a Roku", message: "Please start search again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateRoku(roku: String) {
        RokuResolver.saveRoku(roku: roku)
        NotificationCenter.default.post(name: NSNotification.Name("ROKUFOUND"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }

}

extension ResolverViewController: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_: SSDPDiscovery, didDiscoverService: SSDPService) {
        guard didDiscoverService.searchTarget == "roku:ecp", let loc = didDiscoverService.location else {
            return
        }
        print("Found roku at \(loc)}")
        DispatchQueue.main.async {
            self.rokus.append(loc)
            self.table.reloadData()
            
        }
    }
}

extension ResolverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rokus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RokuCell") {
            cell.textLabel?.text = rokus[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

extension ResolverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateRoku(roku: rokus[indexPath.row])
    }
}
