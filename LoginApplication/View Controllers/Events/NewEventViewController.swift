//
//  NewEventViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 14/03/2022.
//

import UIKit

class NewEventViewController: UIViewController {
    
    
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    

    @IBOutlet weak var searchForFriends: UIButton!
    
    var otherUser = ""
    var invitation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setting date of date picker to current date
        datePicker.date = Date()
        
    }
    
    @IBAction func saveEvent(_ sender: Any) {
        //Adding a new event
        let date = CalendarHelper.dateFormatter.string(from: Date())
        let eventId = createEventId()
        let guardedGame = nameTF.text?.replacingOccurrences(of: " ", with: "")
        guard !(guardedGame!.isEmpty),
              !(eventId.isEmpty) else{
                  return
        }
        
        
        DatabaseManager.shared.createNewEvent(eventId: eventId, dateOfEvent: date, otherUserEmail: otherUser, String: invitation,  nameOfEvent: guardedGame!, completion: { success in
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
        let newID = "\(name)_\(safeCurrentEmail)_\(otherUser)_\(dateString)"
        
        return newID
    }

    
 
    @IBAction func searchForFriends(_ sender: Any) {
        let vc = NewConversationViewController()
        //weak self to stop memory retention cycle
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.sendInviteRequest(result: result)
        }
        let newConversationVC = UINavigationController(rootViewController: vc)
        present(newConversationVC, animated: true)
    }
    
    private func sendInviteRequest(result: [String: String]) {
        guard let username = result["username"], let email = result["email"] else {
            return
        }
        friendLabel.text = username
        otherUser = email
        invitation = true
    }
    
}
