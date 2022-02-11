//
//  LoginViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import Elements
import FirebaseAuth
//import FBSDKKit

class LoginViewController: UIViewController {
    
    //-------------------Ellements  ==============================
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    lazy var iconImageView : BaseUIImageView = {
        let imageView = BaseUIImageView()
        imageView.image = UIImage(named: "icon500")
        return imageView
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
    
    
    lazy var inputStack : VStack = {
        let stack = VStack()
        stack.addArrangedSubview(emailTF)
        stack.addArrangedSubview(passTF)
        stack.spacing = 15
        return stack
    }()
    
    lazy var loginButton: BaseUIButton = {
        let button = BaseUIButton()
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.systemGreen
        button.layer.shadowOpacity = 1.0
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(loginHandler), for: .touchUpInside)
        return button
    }()
    
//    lazy var facebookLoginButton : FBLoginButton = {
//        let loginButton = FBLoginButton()
//        loginButton.center = scrollView.centr
//        loginButton.frame.origin.y = loginButton.bottom+20
//    button.permissions = ["email", "public_profile"]
//    return loginButton
//    }()
    
    
    // ============================== Viww ==============================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        title = "Log in"
        
        view.addSubview(scrollView)
        scrollView.addSubview(iconImageView)
        scrollView.addSubview(inputStack)
        scrollView.addSubview(loginButton)
//        scrollView.addSubView(loginButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        
            iconImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50),
            iconImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 2/7),
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
            
            inputStack.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 50),
            inputStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            inputStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 5/7),
            
            loginButton.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 50),
            loginButton.centerXAnchor.constraint(equalTo: inputStack.centerXAnchor),
            loginButton.widthAnchor.constraint(equalTo: inputStack.widthAnchor, multiplier: 5/7),
        ])
        
        emailTF.delegate = self
        passTF.delegate = self
        
        //facebookLoginButton.delegate = self
        

        
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
        emailTF.resignFirstResponder()
        passTF.resignFirstResponder()
        
        guard let email = emailTF.text , !email.isEmpty,
              let password = passTF.text, !password.isEmpty, password.count >= 8 else {
                  errorAlert()
                  return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let strongSelf = self else { return }
            guard let result = authResult, error == nil else {
                print("error occured")
                return
            }
            
            let user = result.user
            print("==================logged in successfully with this user: \(user)=================")
            
            strongSelf.navigationController?.dismiss(animated: true,completion: nil)
            
        }
        
        
//        let vc = ConversationViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}


extension LoginViewController : UITextFieldDelegate{
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

//extension LoginViewController : LoginButtonDelegate{
//    func loginButtonDidLogOut(_LoginButton: FBLoginButton){
//
//    }
//
//    func loginButton(_loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?){
//
//
//        guard let token = result.token.tokenString else {
//            print("User failed to log in with facebook")
//            return
//        }
//        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me"
//                                                         parameters: ["friends": "email, name"],
//                                                         tokenString: token,
//                                                         version: nil,
//                                                         httpMethod: .get)
//        facebookRequest.start(completionHandler: { _, result, error in
//            guard let result = result as [String: Any],
//            error == nil else{
//                print("Failed to make facebook graph request.")
//                return
//            }
//
//            guard let userName = result["name"] as? String,
//            let email = result["email"] as? String else{
//                print("Failed to get email and Name from fb result.")
//            }
//
//            let nameComponents = userName.components(separatedBy: " ")
//            guard nameComponents.count == 2 else{ return }
//            let firstName = nameComponents[0]
//            let lastName = nameComponents[1]
//            let userName = firstName + lastName
//            DatabaseManger.shared.userExists(with: email) { exists in
//                if !exists{
//                    DatabaseManager.shared.insertUser(with: ChatAppUser(userName: userName, email: email))
//                }
//            }
//
//        })
//// 
//        let credential = FacebookAuthProvider.credential(withAccessToken: token)
//        FirebaseAuth.Auth.auth().signIn(with: Credentials, completion: { [weak self] authResult, error in
//            guard let strongSelf = self else { return }
//            guard authResult != nil, error == nil else{ return }
//            print("Successfully logged a user in")
//            strongSelf.navigationController.dismiss(animated: true, completion: nil)
//        })
//
//    }
//}
