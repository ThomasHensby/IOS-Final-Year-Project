//
//  InvitedEventViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/03/2022.
//

import UIKit

class InvitedEventViewController: UIViewController {
    
    @IBOutlet weak var noEvents: UILabel!
    
    private var invitedEvent = Event().self
    public var invitationToEvent = [Event]()
    var selectedDate = Date()

    @IBOutlet weak var invitesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     
        invitesTableView.register(InvitedEventTableViewCell.self, forCellReuseIdentifier: InvitedEventTableViewCell.identifier)
        invitesTableView.delegate = self
        invitesTableView.dataSource = self
        listenForEvent()
        invitesTableView.reloadData()
        
    }
    
    func listenForEvent(){
        
        DatabaseManager.shared.getAllEvents(completion: { [weak self] result in
            switch result{
            case .success(let invitations):
                print("successFully got event models")
                self?.invitationToEvent.removeAll()
                guard !invitations.isEmpty else{
                    return
                }
                for event in invitations {
                    if(event.invite == true && event.from == event.inviteWith)  {
                        self?.invitationToEvent.append(event)
                    }
                }
                DispatchQueue.main.async {
                    self?.invitesTableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get events \(error)")
            }
        })
    }
   

    

}
extension InvitedEventViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(invitationToEvent.count != 0){
            noEvents.alpha = 0
        }
        return invitationToEvent.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = invitationToEvent[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: InvitedEventTableViewCell.identifier, for: indexPath) as! InvitedEventTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        return .delete
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //begin delete
            guard let invitedUser = invitationToEvent[indexPath.row].inviteWith else {return}
            guard let user = invitationToEvent[indexPath.row].from else {return}
            let email = UserDefaults.standard.value(forKey: "email") as! String
            let currentEmail = DatabaseManager.safeEmail(email: email)
            guard let eventId = invitationToEvent[indexPath.row].eventId else { return }
            tableView.beginUpdates()
            self.invitationToEvent.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            if(invitedUser == user){
                DatabaseManager.shared.deleteEvent(email: invitedUser, eventId: eventId, completion: { success in
                    if !success { print("delete failed")}
                })
                DatabaseManager.shared.deleteEvent(email: currentEmail, eventId: eventId, completion: { success in
                    if !success { print("delete failed")}
                })
                
                tableView.endUpdates()
            }
        }
    }
    
}
