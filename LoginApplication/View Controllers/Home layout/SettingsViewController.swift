//
//  SettingsViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UIViewController  {

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
        
        presentPhotoActionSheet()
        
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
    
    func addNewProfilePicture() {
        let email = UserDefaults.standard.value(forKey: "email") as! String
        let safeEmail = DatabaseManager.safeEmail(email: email )
        guard let image = self.profilePicture.image, let data = image.pngData() else{
            return
        }
        let fileName = "\(safeEmail)_profile_picture.png"
        StorageManager.shared.deletePicture(email: safeEmail)
        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {
            result in
            switch result{
            case .success(let downloadUrl):
                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
            case .failure(let error):
                print("storage manager error \(error)")
            }
        })
    }
    
    
}

extension SettingsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Create a popup for when user clicks on profile picture
    func presentPhotoActionSheet(){
        //action sheet pulls up from bottom asking what the user would like to use
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        //building 3 buttons in actionview to cancel, take photo or choose photo
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {[weak self]_ in
                                            self?.presentCamera()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: {[weak self]_ in
                                            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    //fucntion to show camera view
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    //function to show users photos
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    //function when user selects a photo from their photolibrary to edit with
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.profilePicture.image = selectedImage
        addNewProfilePicture()
        }
        
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

