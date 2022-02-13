//
//  ProfileViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import FirebaseAuth
import Elements

class ProfileViewController: UIViewController {

    
    //==================== Elements =====================
    @IBOutlet var tableView: UITableView!
    let data = ["Cnage profilePicture", "Log out", "Delete account"]
    
    
    
    //==================== Views =====================
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
     }
    
    
    //==================== Functions =====================
    func createTableHeader() -> UIView?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {return nil}
    
        let safeEmail = DatabaseManager.sefeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = BaseUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = BaseUIImageView(frame: CGRect(x: (headerView.bounds.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)
        return  headerView
    }
}


extension ProfileViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
            
            let alertView = UIAlertController(title: "Log out", message: "would you like to log out?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
                
                guard let strongSelf = self else{
                    return
                }
                
//                FBSDKLoginKit.LoginManager().logOut()
                
                do{
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                }catch{
                    print("Failed to log out")
                }
            }
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            
            alertView.addAction(yesAction)
            alertView.addAction(noAction)
            present(alertView, animated: true)
            
        
    }
}

extension ProfileViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
       // let item = data[indexPath.row]
        
        cell.textLabel?.textColor = .red
        
        return cell
    }
    
    
    
}
