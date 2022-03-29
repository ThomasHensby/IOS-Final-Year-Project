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
        datePicker.date = Date()
        
    }
    
    @IBAction func saveEvent(_ sender: Any) {
        //Adding a new event
        let date = CalendarHelper.dateFormatter.string(from: datePicker.date)
        let eventId = createEventId()
        let guardedGame = nameTF.text?.replacingOccurrences(of: " ", with: "")
        guard !(guardedGame!.isEmpty),
              !(eventId.isEmpty) else{
                  return
        }
        
        
        DatabaseManager.shared.createNewEvent(eventId: eventId, dateOfEvent: date, nameOfEvent: guardedGame!, completion: { [weak self] success in
            if success{
                print("event sent")
            }
            else{
                print("Failed to send event")
            }
        })
        //go back to schdule after saving event
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(identifier: "mainNav")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainNav)
        
        
        
    }
    
    ///Create a unique ID
    private func createEventId() -> String{
        //date, otherUserEmail, senderEmail, random int
        let dateString = CalendarHelper.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return ""
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentUserEmail as! String)
        let name = nameTF.text!
        let newID = "\(name)_\(safeCurrentEmail)_\(dateString)"
        
        return newID
    }

    
 

}
