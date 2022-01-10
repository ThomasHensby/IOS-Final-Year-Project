//
//  ViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/12/2021.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
    }

    func setUpElements() {
        errorLabel.alpha = 0
        //styling
        Utilities.styleHollowButton(loginButton)
        
        Utilities.styleFilledButton(signUpButton)
    }
}

