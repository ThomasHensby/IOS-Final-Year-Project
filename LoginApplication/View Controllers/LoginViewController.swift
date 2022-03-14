//
//  LoginViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 10/01/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    
 
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    

    func setUpElements() {
        //Hiding Label
        errorLabel.alpha = 0
        //Setting Up styling
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
        
    }
    

    @IBAction func loginTapped(_ sender: Any) {
        
        //validate Text Fields
        
        //create cleaned text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Sign in the user
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if error != nil {
                //couldnt sign in
                self.showError("Error signing in")
            }
            else{
                self.transitionToHome()
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
