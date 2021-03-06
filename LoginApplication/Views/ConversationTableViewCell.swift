//
//  CoversationTableViewCell.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 27/03/2022.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "CoversationTableViewCell"
    
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.center.x + 60 ,
                                     y: 10,
                                     width: contentView.frame.width - 20 - userImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.center.x + 60 ,
                                        y: userNameLabel.center.y + 10,
                                     width: contentView.frame.width - 20 - userImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
     
    }
    
    
    public func configure(with model: Conversation)
    {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result{
            case .success(let url):
                //working on main thread as UI
                DispatchQueue.main.async {
                    //using the SDWeb image to handle downloading and working with cache
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("Failed to get image url : \(error)")
            }
        })
    }

}
