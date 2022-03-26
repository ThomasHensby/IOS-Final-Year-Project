//
//  NewConversationViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 19/03/2022.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?
    
    private var users = [[String: String]]()
    
    private var results = [[String: String]]()
    //has fetched is performed in case one user being itself
    private var hasFetched = false

    //create a UI seachbar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for friends..."
        return searchBar
    } ()
    
    //create a UI tableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //create a label to outline no results after search
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.frame.width/4,
                                      y: (view.frame.height-200)/2,
                                      width: view.frame.width/2,
                                      height: 200)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        self.searchUser(query: text)
    }
    
    func searchUser(query: String){
        //check if array has firebase results
        if hasFetched {
            //if it does: filter
            filterUsers(with: query)
        }
        else{
            //if not, fetch then filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                //if getting all users was a success
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error): print("Failed to get users: \(error)")
                }
            })
        }
        
    }
    ///Filter the list of users so only with prefix sent through
    func filterUsers(with term: String) {
        //update the UI: results or no results
        guard hasFetched else {
            return
        }
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["username"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        updateUI()
        
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate{
    
    //viewing all names that pop up based on results array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = results[indexPath.row]["username"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start convo
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
        
        
    }
}
