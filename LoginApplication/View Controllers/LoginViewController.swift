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
        //Sign in the user and weak self stops retention cycle
        Auth.auth().signIn(withEmail: email, password: password, completion:  { [weak self] result, error in
            guard let strongSelf = self else{
                return
            }
            //check for errors
            guard let res = result, error == nil else {
                //couldnt sign in
                strongSelf.showError("Error signing in")
                return
            }
            let user = res.user
            
            //saving email
            UserDefaults.standard.set(email, forKey: "email")
            
            let safeEmail = DatabaseManager.safeEmail(email: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let username = userData["username"] as? String else {
                        return
                    }
                    UserDefaults.standard.set(username, forKey: "username")

                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            
            print("logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            strongSelf.transitionToHome()
            
        })
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
