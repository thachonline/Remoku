//
//  ViewController.swift
//  Remote
//
//  Created by Jack Weber on 8/27/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let controls = Controls(ip: "192.168.0.136")

    @IBOutlet weak var swipeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        swipeView.layer.cornerRadius = 10
    }
    
    @IBAction func press(_ sender: Any) {
        controls.keypress(key: .power)
    }
    @IBAction func volUp(_ sender: Any) {
        controls.keypress(key: .volumeUp)
    }
    @IBAction func volDown(_ sender: Any) {
        controls.keypress(key: .volumeDown)
    }
    @IBAction func mute(_ sender: Any) {
        controls.keypress(key: .mute)
    }
    @IBAction func right(_ sender: Any) {
        controls.keypress(key: .right)
    }
    @IBAction func left(_ sender: Any) {
        controls.keypress(key: .left)
    }
    @IBAction func up(_ sender: Any) {
        controls.keypress(key: .up)
    }
    @IBAction func down(_ sender: Any) {
        controls.keypress(key: .down)
    }
    @IBAction func back(_ sender: Any) {
        controls.keypress(key: .back)
    }
    @IBAction func home(_ sender: Any) {
        controls.keypress(key: .home)
    }
    @IBAction func ok(_ sender: Any) {
        controls.keypress(key: .ok)
    }
}

