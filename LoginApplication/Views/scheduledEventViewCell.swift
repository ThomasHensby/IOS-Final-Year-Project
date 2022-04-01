//
//  scheduledEventViewCell.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 29/03/2022.
//

import UIKit
import SDWebImage

class scheduledEventViewCell: UITableViewCell {
    
    static let identifier = "scheduledEventViewCell"
    
    static let shared = scheduledEventViewCell()
    
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
    
    private let eventFromLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .regular)
        return label
    }()
    
    private let eventMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    

    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(gameImageView)
        contentView.addSubview(eventNameLabel)
        contentView.addSubview(eventMessageLabel)
        contentView.addSubview(eventFromLabel)
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
        eventMessageLabel.frame = CGRect(x: gameImageView.center.x + 60 ,
                                        y: eventNameLabel.center.y + 10,
                                     width: contentView.frame.width - 20 - gameImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
        eventFromLabel.frame = CGRect(x: gameImageView.center.x + 60 ,
                                        y: eventMessageLabel.center.y + 10,
                                     width: contentView.frame.width - 20 - gameImageView.center.x + 60,
                                     height: (contentView.frame.height - 20)/2)
    }
    
    
    
    public func configure(with model: Event)
    {
        let date = CalendarHelper.dateFormatter.date(from: model.date)
        self.eventMessageLabel.text = CalendarHelper().timeString(date: date!)
        self.eventNameLabel.text = model.name
        if(!model.from.isEmpty){
            DatabaseManager.shared.getDataFor(path: model.inviteWith, completion: { [weak self] result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let username = userData["username"] as? String else {
                        return
                    }
                    if(username != UserDefaults.standard.value(forKey: "username") as! String){
                        self?.eventFromLabel.text = "With: \(username)"
                    }
                    else{
                        self?.eventFromLabel.text = "Solo event"
                    }
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
        }
        self.eventFromLabel.text = "Solo event"
        let cleanedName = model.name.trimmingCharacters(in: .whitespaces).lowercased()
        var path = ""
        if !cleanedName.isEmpty{
            switch model.name{
            case "callofduty": path = "games/callofduty.jpg"
            case "valorant": path = "games/valorant.png"
            case "csgo": path = "games/csgo.png"
            case "siege": path = "games/siege.jpg"
            case "apexlegends": path = "games/apexlegends.jpg"
            default: path = "games/defaultImage.png"
            }
            
            StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                switch result{
                case .success(let url):
                    //working on main thread as UI
                    DispatchQueue.main.async {
                        //using the SDWeb image to handle downloading and working with cache
                        self?.gameImageView.sd_setImage(with: url, completed: nil)
                    }
                case .failure(let error):
                    print("Failed to get image url : \(error)")
                }
            })
        }
    }
}
