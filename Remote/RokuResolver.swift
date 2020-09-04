//
//  RokuResolver.swift
//  Remote
//
//  Created by Jack Weber on 8/29/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit
import SSDPClient

class RokuResolver: NSObject {
    static func getRoku() -> String? {
        return UserDefaults.standard.string(forKey: "roku")
    }
    
    static func saveRoku(roku: String) {
        UserDefaults.standard.setValue(roku, forKey: "roku")
    }
}

class ServiceDiscovery {
    let client = SSDPDiscovery()

    init(delegate: SSDPDiscoveryDelegate) {
        self.client.delegate = delegate
    }
    
    func start() {
        self.client.discoverService()
    }
}
