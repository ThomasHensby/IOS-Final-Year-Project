//
//  SignUpViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 03/01/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class SignUpViewController: UIViewController {

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
    }

    func validateFields() -> String? {
        //check for whitespaces
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "please fill in all fields."
        }
        //check for a good password
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            //password isnt secure
            return "Please make sure your password is at /n least 8 characters, contains a special character and a number."
        }
        
        return nil
    }

    
    @IBAction func signUpTapped(_ sender: Any) {
        
        //validation
        let error = validateFields()
        if error != nil {
            //something wrong with fields
            showError(error!)
            
        }
        else {
            //create cleaned data
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result , err) in
                
                //check for errors
                if err != nil{
                    //error creating the user
                    self.showError("Error Creating User")
                }
                else{
                    //user was created successfully,now store the username
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data:["username":username , "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            //SHOW ERROR MESSAGE
                            self.showError("error saving user data")
                        }
                    }
                    
                    //transition to homepage
                    self.transitionToHome()
                    
                }
            }
            
            
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
