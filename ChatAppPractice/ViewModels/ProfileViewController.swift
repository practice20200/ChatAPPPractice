//
//  ProfileViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let data = ["Cnage profilePicture", "Log out", "Delete account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
     }
    

  

}


extension ProfileViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
            
            let alertView = UIAlertController(title: "Log out", message: "would you like to log out?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
                
                guard let strongSelf = self else{
                    return
                }
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
