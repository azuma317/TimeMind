//
//  AddRoomViewController.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/20.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit
import Photos

class AddRoomViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var roomNameField: UnderLineTextField!
    @IBOutlet weak var roomImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addLeftBarButtonWithString("✕")
        addRightBarButtonWithString("保存")
    }
    
    func addLeftBarButtonWithString(_ buttonString: String) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    func addRightBarButtonWithString(_ buttonString: String) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: buttonString, style: .plain, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        return true
    }
    
    @objc func close() {
        roomNameField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        roomNameField.resignFirstResponder()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.roomImageView.image = pickedImage
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
