//
//  RegisterViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import Elements
import FirebaseAuth

class RegisterViewController: UIViewController, UINavigationControllerDelegate {

    //==========================   Ellements  ==============================
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    lazy var iconImageView : BaseUIImageView = {
        let imageView = BaseUIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.layer.cornerRadius = 100
        return imageView
    }()
    
    lazy var userNameTF: BaseUITextField = {
        let tf = BaseUITextField()
        tf.placeholder = "User Name"
        tf.returnKeyType = .continue
        tf.backgroundColor = UIColor.white
        tf.layer.shadowOpacity = 1.0
        tf.layer.shadowColor = UIColor.lightGray.cgColor
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.layer.cornerRadius = 15
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        return tf
    }()
    
    lazy var emailTF: BaseUITextField = {
        let tf = BaseUITextField()
        tf.placeholder = "Email"
        tf.returnKeyType = .continue
        tf.backgroundColor = UIColor.white
        tf.layer.shadowOpacity = 1.0
        tf.layer.shadowColor = UIColor.lightGray.cgColor
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.layer.cornerRadius = 15
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        tf.backgroundColor = .white
        return tf
    }()
    
    lazy var passTF: BaseUITextField = {
        let tf = BaseUITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor.white
        tf.layer.shadowOpacity = 1.0
        tf.layer.shadowColor = UIColor.lightGray.cgColor
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tf.layer.cornerRadius = 15
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var passwordRuleLabel : BaseUILabel = {
        let label =  BaseUILabel()
        label.text = "Password has to be more than 8 words."
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.systemRed
        label.numberOfLines = 2
        return label
    }()
    
    
    lazy var inputStack : VStack = {
        let stack = VStack()
        stack.addArrangedSubview(userNameTF)
        stack.addArrangedSubview(emailTF)
        stack.addArrangedSubview(passTF)
        stack.addArrangedSubview(passwordRuleLabel)
        stack.spacing = 15
        return stack
    }()
    
    lazy var registerButton: BaseUIButton = {
        let button = BaseUIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.shadowOpacity = 1.0
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(loginHandler), for: .touchUpInside)
        return button
    }()
    
    
    // ============================== Viww ==============================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Log in"
        
        view.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        scrollView.addSubview(inputStack)
        scrollView.addSubview(registerButton)
        
        iconImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        
            iconImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50),
            iconImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//            iconImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 2/7),
//            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            
            inputStack.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 50),
            inputStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            inputStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 5/7),
            
            registerButton.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 50),
            registerButton.centerXAnchor.constraint(equalTo: inputStack.centerXAnchor),
            registerButton.widthAnchor.constraint(equalTo: inputStack.widthAnchor, multiplier: 5/7),
        ])
        
        userNameTF.delegate = self
        emailTF.delegate = self
        passTF.delegate = self
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTappedProfileImage))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTapsRequired = 1
        iconImageView.addGestureRecognizer(gesture)
        let registerButton = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerHandler))
        self.navigationItem.rightBarButtonItem = registerButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
    }
    
    
    
    // ============================== Functions ==============================
    func errorAlert(){
        let alert = UIAlertController(title: "Error", message: "Password or email is invalidate. Please enter your log in information again.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    // ============================== Buttons ==============================
    @objc func registerHandler(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loginHandler(){
        userNameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        passTF.resignFirstResponder()
        
        guard let userName = userNameTF.text, !userName.isEmpty,
                let email = emailTF.text , !email.isEmpty,
                  let password = passTF.text, !password.isEmpty, password.count >= 8 else {
                      errorAlert()
                      return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error == nil else{
                print("Error occured")
                return
            }
            
            let user = result.user
            print("Created a new user: \(user)")        }
        
        let vc = ConversationViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTappedProfileImage(){
        print("Change picture request")
        presentPhotoActionSheet()
    }
    

}


extension RegisterViewController : UITextFieldDelegate{
    // when users enter, automatically move to the next page
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF{
            passTF.becomeFirstResponder()
        }else if textField == passTF{
            loginHandler()
        }
        
        return true
    }

}


extension RegisterViewController: UIImagePickerControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select your picture?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default) { [weak self] _ in
            self?.presentCamera()
        }
        let selectPhotoAction = UIAlertAction(title: "Choose a photo", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(selectPhotoAction)
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    //when users chose
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.iconImageView.image = selectImage
    }
    
    // users cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
