//
//  ViewController.swift
//  Remote
//
//  Created by Jack Weber on 8/27/20.
//  Copyright © 2020 Jack Weber. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    var controls: Controls? = Controls(ip: "")

    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var swipeInstructionLabel: UILabel!
    @IBOutlet weak var dpadView: UIView!
    @IBOutlet weak var textInputView: UIView!
    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var channelsView: UICollectionView!
    
    let feedback = UIImpactFeedbackGenerator(style: .medium)
    
    var attemptedToLoadPurchases = false
    var productsForPurchase = [SKProduct]()
    var apps = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        swipeView.layer.cornerRadius = 10
        swipeInstructionLabel.isHidden = true
        textView.delegate = self
        // textView.layer.opacity = 0
        channelsView.dataSource = self
        channelsView.delegate = self
        channelsView.collectionViewLayout = UICollectionViewFlowLayout()
        textView.text = "\u{200B}"
        NotificationCenter.default.addObserver(self, selector: #selector(updateControls), name: NSNotification.Name(rawValue: "ROKUFOUND"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(savePurchase), name: NSNotification.Name(rawValue: "IAPHandlerPurchaseNotification"), object: nil)
        // Load in app purchases
        IAPHandler.shared.getProducts { (result) in
            print("HERE - Finding Products")
            self.attemptedToLoadPurchases = true
            if let products = try? result.get() {
                for p in products {
                    print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
                }
                self.productsForPurchase = products
            } else {
                print("Could not find any products.")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updateControls()
        tabView.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "defaultTab")
        tabChange(0)
    }
    
    private func addInnerShadow(v: UIView) {
        let innerShadow = CALayer()
        innerShadow.frame = v.bounds
        // Shadow path (1pt ring around bounds)
        let path = UIBezierPath(rect: innerShadow.bounds.insetBy(dx: -1, dy: -1))
        let cutout = UIBezierPath(rect: innerShadow.bounds).reversing()
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 0.05
        innerShadow.shadowRadius = 3
        innerShadow.cornerRadius = v.frame.size.height/2
        v.layer.addSublayer(innerShadow)
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
        controls?.getApps(completion: { (ids) in
            self.apps = ids
            DispatchQueue.main.async {
                self.channelsView.reloadData()
            }
        })
    }
    
    @IBOutlet weak var tabView: UISegmentedControl!
    
    @IBAction func tabChange(_ sender: Any) {
        let views = [swipeView, dpadView, textInputView]
        for view in views {
            view?.isHidden = true
        }
        textView.resignFirstResponder()
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
            validatePurchase()
            channelsView.isHidden = false
            if self.apps.count == 0 {
                controls?.getApps(completion: { (ids) in
                    self.apps = ids
                    DispatchQueue.main.async {
                        self.channelsView.reloadData()
                    }
                })
            }
            break
        case 3:
            // Show keyboard
            validatePurchase()
            textInputView.isHidden = false
            textView.becomeFirstResponder()
            break
        default:
            break
        }
    }
    
    // Check for purchases
    func validatePurchase() {
        if UserDefaults.standard.bool(forKey: "Pro") {
            return
        }
        
        if attemptedToLoadPurchases && productsForPurchase.count == 0 {
            let alert = UIAlertController(title: "Requires Pro Version", message: "Cannot connect to appstore, please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        if !attemptedToLoadPurchases && productsForPurchase.count == 0 {
            let alert = UIAlertController(title: "Requires Pro Version", message: "Still waiting to connect to appstore, please try later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        if productsForPurchase.count > 0{
            let alert = UIAlertController(title: "Requires Pro Version", message: "Please consider supporting the developer and purchasing pro version for $\(productsForPurchase[0].price)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Purchase", style: .default, handler: { (_) in
                IAPHandler.shared.buyProduct(self.productsForPurchase[0])
            }))
            alert.addAction(UIAlertAction(title: "Restore", style: .default, handler: { (_) in
                IAPHandler.shared.restorePurchases()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        tabView.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "defaultTab")
        self.tabChange("nil")
    }
    
    @objc func savePurchase() {
        print("SAVE PURCHASE")
        if IAPHandler.shared.purchasedProductIdentifiers.count > 0 {
            let alert = UIAlertController(title: "Pro Version Enabled", message: "Pro Version has been successfully purchased", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            UserDefaults.standard.set(true, forKey: "Pro")
        }
    }
    
    // KEYPRESSES
    func buttonPressed() {
        feedback.impactOccurred()
        // print("pressed button")
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
    @IBAction func textInputChange(_ sender: Any) {
        if var input = textView.text {
            textView.text = "\u{200B}"
            if input != "", let key = Array(input).last {
                input = String(key)
            }
            controls?.keyboardPress(key: input)
        }
    }
    @IBAction func settings(_ sender: Any) {
        self.performSegue(withIdentifier: "SettingsSegue", sender: nil)
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

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        size.width = floor(channelsView.frame.width / 2) - 20
        size.height = floor(size.width * (3 / 4))
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        apps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        controls?.launch(id: apps[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath)

        if let appcell = cell as? AppCell, let url = URL(string: controls?.GetAppImageUrl(id: apps[indexPath.row]) ?? ""), let image = try? UIImage(data: Data(contentsOf: url)) {
            appcell.imageView.image = image
            let text = apps[indexPath.row]
            if text.contains(".") {
                appcell.label.text = "\(text.split(separator: ".")[1])"
            } else {
                appcell.label.text = ""
            }
            return appcell
        }
        
        return cell
    }
    
    
}

class AppCell: UICollectionViewCell {
    var imageView = UIImageView()
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.updateViews()
    }
    
    func updateViews() {
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(label)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        //label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()

        imageView.layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        
        contentView.backgroundColor = .gray
//        contentView.layer.shadowColor = UIColor.black.cgColor
//        contentView.layer.shadowRadius = 1
//        contentView.layer.shadowOpacity = 1
//        contentView.layer.shadowOffset = .zero
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        self.updateViews()
    }
}
