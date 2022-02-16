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
    let sectionData = ["Cnage profilePicture", "Log out", "Delete account"]
    
    
    
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
    
        let safeEmail = DatabaseManager.sefeEmail(email: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = BaseUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        headerView.backgroundColor = .link
        
        let imageView = BaseUIImageView(frame: CGRect(x: (headerView.frame.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)
        
        print("test2")
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            print("test3")
            print("images/ + fileName:     \("images/" + fileName)")
            
            switch result {
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        }

        return  headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}


extension ProfileViewController : UITableViewDelegate{
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sectionData[indexPath.row] == "Log out" {
            print("koko: \(sectionData[indexPath.row])")
            logOutHandler()
        }
    }
    
    func logOutHandler(){
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
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sectionData[indexPath.row]
       // let item = data[indexPath.row]
        
        cell.textLabel?.textColor = .red
        
        return cell
    }
    
    
    
}
