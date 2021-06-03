//
//  CreatePostVC.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol IInputView: AnyObject {
    func input(_ data: Any?)
    
    func showError(message: String)
}

protocol CreatePostView : AnyObject, IInputView {
    func goBack()
    
    func setupPost(image: String?, text: String)
    
    func setTitle(title: String)
}

class CreatePostVC: UIViewController, CreatePostView {
    lazy var presenter: ICreatePostPresenter? = {
        return CreatePostPresenter.setup(view: self)
    }()
    @IBOutlet weak var scroll: UIScrollView!
    private var picker: UIImagePickerController? = nil
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.setupContent()
    }
    
    @IBAction func onPublish(_ sender: Any) {
        self.postText.resignFirstResponder()
        self.presenter?.post()
    }
    
    func setTitle(title: String){
        self.title = title
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.postText.delegate = self
        self.registerKeyboardNotifications()
        self.setupMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.postText.delegate = nil
        self.unregisterKeyboardNotifications()
        super.viewWillDisappear(animated)
    }
    
    func setupMenu() {
        let addButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(addPost))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addPost() {
        self.postText.resignFirstResponder()
        self.presenter?.post()
    }
    
    @IBAction func onAddImageClicked(_ sender: Any) {
        self.showSelectImage()
    }
    
    @IBAction func onTouched(_ sender: Any) {
        self.postText.resignFirstResponder()
    }
    func showSelectImage() {
        let actionDialog = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionDialog.addAction(UIAlertAction(title: "Pick from gallery", style: .default, handler: {(action) in
            PhotoHelper.shared.listener = self
            PhotoHelper.shared.requestPhotos()
        }))
        
        actionDialog.addAction(UIAlertAction(title: "Shoot photo" , style: .default, handler: {[weak self] (action) in
            CameraHelper.shared.listener = self
            CameraHelper.shared.requestCamera()
        }))
        actionDialog.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:nil))
        self.present(actionDialog, animated: true, completion: nil)
    }
    
    private func showAddFromGallery() {
        DispatchQueue.main.async {
            self.picker = UIImagePickerController()
            self.picker?.delegate = self
            self.picker?.sourceType = .photoLibrary
            self.present(self.picker!, animated: true, completion: nil)
        }
    }
    
    private func showAddFromCamera() {
        DispatchQueue.main.async {
            self.picker = UIImagePickerController()
            self.picker?.delegate = self
            self.picker?.sourceType = .camera
            self.present(self.picker!, animated: true, completion: nil)
        }
    }
    
    func input(_ data: Any?) {
        if let data = data as? PostItem {
            self.presenter?.setup(post: data)
        }
    }
    
    func setupPost(image: String?, text: String) {
        self.postText.text = text
        if let link = image {
            ImageStorage.sharedInstance.setupImage(imageKey: link, imageView: self.postImage)
        }
    }
}

extension CreatePostVC {
 func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

}

func unregisterKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

}

@objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scroll!.contentInset = contentInsets

    }

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}


@objc func keyboardWillHide(notification: NSNotification) {
    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    scroll!.contentInset = contentInsets
   scroll!.scrollIndicatorInsets = contentInsets

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}
}

extension CreatePostVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.presenter?.setupText(text: textView.text)
    }
}

extension CreatePostVC : PhotoAccessListener {
    func accessGranted() {
        DispatchQueue.main.async {
            self.showAddFromGallery()
        }
    }
    
    func accessDenied() {
        DispatchQueue.main.async {
            self.showMessage(message: "No Photo Access") {
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension CreatePostVC: CameraAccessListener {
    func requestAccess(completion: () -> Void) {
        
    }
    
    
    func cameraAccessGranted() {
        DispatchQueue.main.async {
            self.showAddFromCamera()
        }
    }
    
    func cameraAccessDenied() {
        DispatchQueue.main.async {
            self.showMessage(message: "No Camera Access") {
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
}

extension CreatePostVC :  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        image.resize(newSize:CGSize(width: 512,height: 512)) {[weak self](im, imdata) in
            self?.postImage.image = im
            if let data = imdata {
                self?.presenter?.setupImage(data: data)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

