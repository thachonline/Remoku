//
//  Controls.swift
//  Remote
//
//  Created by Jack Weber on 8/27/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit

public enum Keypress: String {
    case left = "LEFT"
    case right = "RIGHT"
    case up = "UP"
    case down = "DOWN"
    case volumeUp = "VOLUMEUP"
    case volumeDown = "VOLUMEDOWN"
    case mute = "VOLUMEMUTE"
    case power = "POWER"
    case home = "HOME"
    case back = "BACK"
    case ok = "SELECT"
}

class Controls: NSObject {
    let ip: String
    
    init(ip :String) {
        self.ip = ip
        super.init()
    }
    
    func keypress(key: Keypress) {
        self.stroke(fullRequest: "keypress/" + key.rawValue)
    }
    
    private func stroke(fullRequest: String) {
        if let url = URL(string: "http://" + ip + ":8060/" + fullRequest){
            print(url.absoluteString)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            URLSession.shared.dataTask(with: req).resume()
        }
    }
}
