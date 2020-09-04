//
//  ViewController.swift
//  Remote
//
//  Created by Jack Weber on 8/27/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var controls: Controls? = Controls(ip: "")

    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var swipeInstructionLabel: UILabel!
    @IBOutlet weak var dpadView: UIView!
    @IBOutlet weak var textInputView: UIView!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var channelsView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        swipeView.layer.cornerRadius = 10
        swipeInstructionLabel.isHidden = true
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateControls), name: NSNotification.Name(rawValue: "ROKUFOUND"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateControls()
        tabView.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "defaultTab")
        tabChange(0)
    }
    
    // OTHER FUNCTIONS
    func openResovler(){
        self.performSegue(withIdentifier: "ResolverSegue", sender: controls)
    }
    
    @objc func updateControls() {
        if let roku = RokuResolver.getRoku() {
            controls = Controls(ip: roku)
        } else {
            swipeInstructionLabel.isHidden = false
            self.openResovler()
        }
    }
    
    @IBOutlet weak var tabView: UISegmentedControl!
    
    @IBAction func tabChange(_ sender: Any) {
        let views = [swipeView, dpadView, textInputView]
        for view in views {
            view?.isHidden = true
        }
        switch tabView.selectedSegmentIndex {
        case 0:
            swipeView.isHidden = false
            UserDefaults.standard.set(0, forKey: "defaultTab")
            break
        case 1:
            dpadView.isHidden = false
            UserDefaults.standard.set(1, forKey: "defaultTab")
            break
        case 2:
            // Show Channels
            channelsView.isHidden = false
            break
        case 3:
            // Show keyboard
            textInputView.isHidden = false
            textView.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    // KEYPRESSES
    func buttonPressed() {
        if !swipeInstructionLabel.isHidden {
            UIView.animate(withDuration: 1) {
                self.swipeInstructionLabel.layer.opacity = 0
            }
        }
    }
    
    @IBAction func press(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .power)
    }
    @IBAction func volUp(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .volumeUp)
    }
    @IBAction func volDown(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .volumeDown)
    }
    @IBAction func mute(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .mute)
    }
    @IBAction func right(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .right)
    }
    @IBAction func left(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .left)
    }
    @IBAction func up(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .up)
    }
    @IBAction func down(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .down)
    }
    @IBAction func back(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .back)
    }
    @IBAction func home(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .home)
    }
    @IBAction func ok(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .ok)
    }
    @IBAction func fwd(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .fwd)
    }
    @IBAction func play(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .play)
    }
    @IBAction func rev(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .rev)
    }
    @IBAction func replay(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .replay)
    }
    @IBAction func star(_ sender: Any) {
        buttonPressed()
        controls?.keypress(key: .star)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        tabView.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "defaultTab")
        tabChange(textField)
        return true
    }
}
