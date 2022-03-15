//
//  NewEventViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 14/03/2022.
//

import UIKit

class NewEventViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setting date of date picker to current date
        datePicker.date = selectedDate
        
    }
    
    @IBAction func saveEvent(_ sender: Any) {
        //Adding a new event
        let newEvent = Event()
        newEvent.id = eventsList.count
        newEvent.name = nameTF.text
        newEvent.date = datePicker.date
        
        //get eventlist and append new event
        eventsList.append(newEvent)
        //go back to previous viewcontroller after saving event
        navigationController?.storyboard?.instantiateViewController(identifier: "mainNav")
        
        
        
    }
    
 

}
