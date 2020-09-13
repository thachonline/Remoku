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
    case backspace = "BACKSPACE"
}

struct App {
    var image: UIImage
    var id: String
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
    
    func keyboardPress(key: String) {
        if (key == ""){
            self.keypress(key: .backspace)
        }
        if (key == " "){
            self.stroke(fullRequest: "keypress/Lit_+")
        }
        else {
            self.stroke(fullRequest: "keypress/Lit_" + key)
        }
    }
    
    func launch(id: String) {
        self.stroke(fullRequest: "launch/" + id)
    }
    
    func getApps(completion: @escaping ([String]) -> Void) {
        if !ip.contains("http") {
            ip = "http://" + ip + ":8060/"
        }
        print(self.ip)
        if let url = URL(string: ip + "query/apps") {
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            URLSession.shared.dataTask(with: req) { (data, res, err) in
                if let r = res as? HTTPURLResponse, r.statusCode == 200, let dataString = String(data: data!, encoding: .utf8) {
                    let regex = try! NSRegularExpression(pattern: "id=\"[^\"]*\"", options: .caseInsensitive)
                    let matches = regex.matches(in: dataString, options: [], range: NSRange(location: 0, length: dataString.count)).map {
                        return dataString.substring(with: $0.range)!.split(separator: "\"")[1]
                    }
                    let strs = matches.map {
                        return "\($0)"
                    }
                    print(strs)
                    completion(strs)
                }
            }.resume()
        }
    }
    
    func GetAppImageUrl(id: String) -> String {
        if !ip.contains("http") {
            ip = "http://" + ip + ":8060/"
        }

        return ip + "query/icon/\(id)"
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

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}
