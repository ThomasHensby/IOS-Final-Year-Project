//
//  SignUpViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 03/01/2022.
//

import UIKit
import FirebaseAuth



class SignUpViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements(){
        //Hiding the error label
        errorLabel.alpha = 0
        //styling of elements
        Utilities.styleTextField(usernameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        //As Dynamically changing image want to change look when image selected
        Utilities.styleProfilePicture(profilePicture)
        //allowing Interaction to be recognised on image view
        profilePicture.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePicture))
        gesture.numberOfTouchesRequired = 1
        profilePicture.addGestureRecognizer(gesture)
        
        
    }

    func validateFields() -> String? {
        //check for whitespaces
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            
            return "please fill in all fields."
        }
        //check for a good password
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //password isnt secure
            return "Please make sure your password is at \n least 8 characters, contains a special character \n and a number."
        }
        
        return nil
    }

   //function for view controller tapped
    @objc private func didTapChangeProfilePicture(_ sender: Any) {
        presentPhotoActionSheet()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //validation
        let error = validateFields()
        if error != nil {
            //something wrong with fields
            
            showError(error!)
            
        }
        else {
            //create cleaned data to input in db
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Check db if email already in use weak self to stop retention issues
            DatabaseManager.shared.userEmailExists(with: email, completion: { [weak self] exists in
                guard let strongSelf = self else{
                    return
                }
                //Checking to see if user exists if does tells user the email is in use
                guard !exists else {
                    //user already exists
                    strongSelf.showError("This email is already in use!")
                    return
                }
                
                //create the user
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result , err in
                    
                    //check for errors
                    guard result != nil, err == nil else{
                        //error creating the user
                        strongSelf.showError("Error Creating User")
                        return
                    }
                    //insert in to firebase realtime db
                    let accountUser = ChatAppUser(username: username,
                                                  email: email)
                    DatabaseManager.shared.insertUser(with: accountUser, completion: {success in
                        if success {
                            //upload image
                            guard let image = strongSelf.profilePicture.image, let data = image.pngData() else {
                                return
                            }
                            let fileName = accountUser.profilePictureFileName
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                                switch result {
                                case .success(let downloadUrl):
                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                    print(downloadUrl)
                                case . failure(let error):
                                    print("storage manager error \(error)")
                                }
                            })
                        }
                    } )
                
                  
                    //transition to homepage
                    strongSelf.transitionToHome()
                    
                })
            })
        }
            
    }
        
        
      
    
    func showError(_  message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(identifier: "mainNav")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainNav)
    }
    
}

extension SignUpViewController : UIImagePickerControllerDelegate {
    
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
        }
        
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
