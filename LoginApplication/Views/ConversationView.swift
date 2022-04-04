//
//  ConversationView.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 04/04/2022.
//

import Foundation
import UIKit

class ConversationView {
    
    static let shared = ConversationView()
    
    //create a UI seachbar
    public let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for friends..."
        return searchBar
    } ()
    
    //create a UI tableView
    public let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    //create a label to outline no results after search
    public let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
}
