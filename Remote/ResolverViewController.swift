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

    override func viewDidLoad() {
        super.viewDidLoad()

        var discovery = ServiceDiscovery(delegate: self)
        discovery.start()
    }

}

extension ResolverViewController: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_: SSDPDiscovery, didDiscoverService: SSDPService) {
        guard didDiscoverService.searchTarget == "roku:ecp", let loc = didDiscoverService.location else {
            return
        }
        print("Found roku at \(loc)}")
        RokuResolver.saveRoku(roku: loc)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ROKUFOUND"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
