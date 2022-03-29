//
//  InvitedEventViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/03/2022.
//

import UIKit

class InvitedEventViewController: UIViewController {
    
    private var invitations = [Event]()

    @IBOutlet weak var invitesTableView: UITableView!
    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
//                                                            target: self, action: #selector(didTapComposeButton))
//        
        invitesTableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        invitesTableView.delegate = self
        invitesTableView.dataSource = self
        
    }
    
   
//    @objc private func didTapComposeButton() {
//        let vc = NewConversationViewController()
//        //weak self to stop memory retention cycle
//        vc.completion = { [weak self] result in
//            print("\(result)")
//            self?.createNewInvite(result: result)
//        }
//        let newConversationVC = UINavigationController(rootViewController: vc)
//        present(newConversationVC, animated: true)
//    }
//
//    func createNewInvite(){
//
//    }
    

}
extension InvitedEventViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let model = Event[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: InvitedEventTableViewCell.identifier, for: indexPath) as! InvitedEventTableViewCell
        //cell.configure(with: model)
        //Arrow to indicate can be clicked into
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
}
