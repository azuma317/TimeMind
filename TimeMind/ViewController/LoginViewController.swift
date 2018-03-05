//
//  LoginViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/19.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit
import Photos

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    @IBOutlet var loginView: UIView!
    @IBOutlet var registerView: UIView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var worningLabel: UILabel!
    @IBOutlet weak var registNameField: UITextField!
    @IBOutlet weak var registEmailField: UITextField!
    @IBOutlet weak var registPasswordField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet var inputField: [UITextField]!
    @IBOutlet weak var profileImageView: RoundImageView!
    
    var loginViewTopConstraint: NSLayoutConstraint!
    var registViewTopConstraint: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    var isLoginViewVisble = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customization()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.layoutIfNeeded()
    }
    
    fileprivate func createMenuView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftMenuViewController
        
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        UINavigationBar.appearance().tintColor = UIColor(hex: "689F38")
        
        let slideMenuController = SlideMenuController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.delegate = mainViewController
        self.present(slideMenuController, animated: true, completion: nil)
    }
    
    func customization() {
        self.darkView.alpha = 0
        self.imagePicker.delegate = self
        self.profileImageView.layer.borderColor = GlobalVariables.blue.cgColor
        self.profileImageView.layer.borderWidth = 2
        // LoginView
        self.view.insertSubview(self.loginView, belowSubview: self.createButton)
        self.loginView.translatesAutoresizingMaskIntoConstraints = false
        self.loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.loginViewTopConstraint = NSLayoutConstraint.init(item: self.loginView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 100)
        self.loginViewTopConstraint.isActive = true
        self.loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.loginView.layer.cornerRadius = 8
        // RegistView
        self.view.insertSubview(self.registerView, belowSubview: self.createButton)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registViewTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.registViewTopConstraint.isActive = true
        self.registerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.registerView.layer.cornerRadius = 8
    }
    
    func showLoading(state: Bool) {
        if state {
            self.darkView.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.5
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { (_) in
                self.spinner.stopAnimating()
                self.darkView.isHidden = true
            })
        }
    }
    
    func pushTomainView() {
        self.createMenuView()
    }
    
    func openImagePicker(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .authorized || status == .notDetermined {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized || status == .notDetermined {
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func switchAction(_ sender: UIButton) {
        if self.isLoginViewVisble {
            self.isLoginViewVisble = false
            sender.setTitle("Login", for: .normal)
            self.loginViewTopConstraint.constant = 1000
            self.registViewTopConstraint.constant = 60
        } else {
            self.isLoginViewVisble = true
            sender.setTitle("Create Now Account", for: .normal)
            self.loginViewTopConstraint.constant = 100
            self.registViewTopConstraint.constant = 1000
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        for item in self.inputField {
            item.resignFirstResponder()
        }
        self.showLoading(state: true)
        User.login(withEmail: self.loginEmailField.text!, password: self.loginPasswordField.text!) { [weak weakSelf = self](status) in
            DispatchQueue.main.async {
                weakSelf?.showLoading(state: false)
                for item in self.inputField {
                    item.text = ""
                }
                if status == true {
                    self.pushTomainView()
                } else {
                    weakSelf?.worningLabel.isHidden = false
                }
            }
            weakSelf = nil
        }
    }
    
    @IBAction func regist(_ sender: UIButton) {
        for item in self.inputField {
            item.resignFirstResponder()
        }
        self.showLoading(state: true)
        User.regiserUser(withName: self.registNameField.text!, email: self.registEmailField.text!, password: self.registPasswordField.text!, profileImg: self.profileImageView.image!) { [weak weakSelf = self](status) in
            DispatchQueue.main.async {
                weakSelf?.showLoading(state: false)
                for item in self.inputField {
                    item.text = ""
                }
                if status == true {
                    self.pushTomainView()
                    weakSelf?.profileImageView.image = UIImage.init(named: "profile pic")
                } else {
                    weakSelf?.worningLabel.isHidden = false
                }
            }
            weakSelf = nil
        }
    }
    
    @IBAction func selectImg(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert: UIAlertAction) in
            self.openImagePicker(source: .camera)
        }
        let photoAction = UIAlertAction(title: "Albam", style: .default) { (alert: UIAlertAction) in
            self.openImagePicker(source: .library)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.worningLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
