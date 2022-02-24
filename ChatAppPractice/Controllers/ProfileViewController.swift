//
//  ProfileViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import FirebaseAuth
import Elements
import SDWebImage

class ProfileViewController: UIViewController {

    
    //==================== Elements =====================
    @IBOutlet var tableView: UITableView!
    var sectionData = ["User Name", "email", "Log out", "Delete account"]
    
    
    
    //==================== Views =====================
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
     }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
    }
    
    
    //==================== Functions =====================
    func createTableHeader() -> UIView?{
        print("test1")
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("email was nil: ")
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        print("====email: \(email)")
        print("====safeEmail: \(safeEmail)")
        
        let headerView = BaseUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.frame.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.layer.masksToBounds = true
//        imageView.clipsToBounds = true
        headerView.addSubview(imageView)
        
        print("test2")
        StorageManager.shared.downloadURL(for: path) { result in
            print("test3")
            print("images/ + fileName:     \("images/" + fileName)")
            
            switch result {
            case .success(let url):
                print("Got donwload url successfully: \(url)")
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }
        return  headerView
    }
    
//    func downloadImage(imageView: UIImageView, url: URL){
//        imageView.sd_setImage(with: url, completed: nil)
////        URLSession.shared.dataTask(with: url) { data, _, error in
////            guard let data = data, error == nil else { return }
////            DispatchQueue.main.async {
////                let image = UIImage(data: data)
////                imageView.image = image
////            }
////        }.resume()
//    }
}


extension ProfileViewController : UITableViewDelegate{
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionData[indexPath.row] == "Log out" {
            print("log out was tapped: \(sectionData[indexPath.row])")
            logOutHandler()
        }
//            else if  sectionData[indexPath.row] == "User Name" {
//            print("user name was tapped: \(sectionData[indexPath.row])")
////            sectionData[indexPath.row] = Auth.auth().currentUser?.value(forKey: "email") as! String
//            sectionData[indexPath.row] = "Changed"
//
//        }
    }
    
    func logOutHandler(){
        let alertView = UIAlertController(title: "Log out", message: "would you like to log out?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) {[weak self] _ in
            
            guard let strongSelf = self else{
                return
            }
            
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
            
            
            
            
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
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0{
            let userName = "User Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No Name")"
            cell.textLabel?.text = userName
            print("userName: \(userName)")
        } else if indexPath.row == 1{
            print("here")
            cell.textLabel?.text = "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No Email")"
            print("here\(String(describing: Auth.auth().currentUser?.email?.description))")
        }else{
            cell.textLabel?.text = sectionData[indexPath.row]
            cell.textLabel?.textColor = .red
        }
            
        
        return cell
    }
    
    
    
}
