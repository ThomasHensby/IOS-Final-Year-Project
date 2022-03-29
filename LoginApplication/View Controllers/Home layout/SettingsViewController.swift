//
//  SettingsViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UIViewController {

    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFilledButton(signOutButton)
        Utilities.styleHollowButton(changePhotoButton)
        getProfilePicture()
        nameLabel.text = "Username: \(UserDefaults.standard.value(forKey: "username") as! String)"
        // Do any additional setup after loading the view.
    }
    
    
    
    ///Function to get the profile photo from firebase
    func getProfilePicture () {
        let email = UserDefaults.standard.value(forKey: "email")
        let safeEmail = DatabaseManager.safeEmail(email: email as! String)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        
        Utilities.styleProfilePicture(profilePicture)
        
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profilePicture.reloadInputViews()
                }
                self?.downloadImage(imageView: (self?.profilePicture)!, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
    
    ///Function to download the image
    func downloadImage(imageView:UIImageView, url: URL){
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            //needs to be on main thread due to UI elements
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
    

   
    @IBAction func changeProfilePicture(_ sender: Any){
        
        
        
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNav = storyboard.instantiateViewController(identifier: "loginNav")
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNav)
            
        }
        catch{
            print("Failed to log out")
        }
            
        
        
    }
}
