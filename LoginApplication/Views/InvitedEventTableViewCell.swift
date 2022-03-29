//
//  InvitedEventTableViewCell.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/03/2022.
//

import UIKit

class InvitedEventTableViewCell: UITableViewCell {

    static let identifier = "InvitedEventTableViewCell"
    
    
    private let gameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let dateMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(gameImageView)
        contentView.addSubview(eventNameLabel)
        contentView.addSubview(dateMessageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gameImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        eventNameLabel.frame = CGRect(x: gameImageView.center.x + 60 ,
                                     y: 10,
                                     width: contentView.frame.width - 20 - gameImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
        dateMessageLabel.frame = CGRect(x: gameImageView.center.x + 60 ,
                                        y: eventNameLabel.center.y + 10,
                                     width: contentView.frame.width - 20 - gameImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
     
    }
    

}
