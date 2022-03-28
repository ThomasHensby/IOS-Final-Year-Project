//
//  ViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/12/2021.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpElements()
        
    }

    func setUpElements() {
        errorLabel.alpha = 0
        //styling
        Utilities.styleHollowButton(loginButton)
        Utilities.styleLogo(logoImage)
        Utilities.styleFilledButton(signUpButton)
    }
    
    
    
                    
}

