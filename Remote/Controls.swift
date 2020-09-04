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
    case star = "INFO"
    case replay = "INSTANTREPLAY"
    case play = "PLAY"
    case fwd = "FWD"
    case rev = "REV"
}

class Controls: NSObject {
    var ip: String
    
    init(ip :String) {
        self.ip = ip
        super.init()
    }
    
    func keypress(key: Keypress) {
        self.stroke(fullRequest: "keypress/" + key.rawValue)
    }
    
    private func stroke(fullRequest: String) {
        if !ip.contains("http") {
            ip = "http://" + ip + ":8060/"
        }

        if let url = URL(string: ip + fullRequest){
            print(url.absoluteString)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            URLSession.shared.dataTask(with: req).resume()
        }
    }
}
