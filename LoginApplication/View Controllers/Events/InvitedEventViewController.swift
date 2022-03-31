//
//  InvitedEventViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/03/2022.
//

import UIKit

class InvitedEventViewController: UIViewController {
    
   
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
    }
    
    func listenForEvent(){
        
        DatabaseManager.shared.getAllEvents(completion: { [weak self] result in
            switch result{
            case .success(let invitations):
                print("successFully got event models")
                guard !invitations.isEmpty else{
                    return
                }
                for event in invitations {
                    if(event.invite == true)  {
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
    
    
}
