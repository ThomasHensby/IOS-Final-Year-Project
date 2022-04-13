//
//  HomeViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 03/01/2022.
//

import UIKit
import MessageKit
import FirebaseAuth


class HomeViewController: UIViewController {
    
    @IBOutlet weak var noEvents: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var menuOut = false
    var selectedDate = Date()
    var totalSquares = [Date]()
    var eventsList = [Event]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.storyboard?.instantiateViewController(withIdentifier: "mainNav")
        noEvents.alpha = 1
        setCellView()
        setWeekView()
        tableView.register(scheduledEventViewCell.self, forCellReuseIdentifier: scheduledEventViewCell.identifier)
        listenForEvent()
        tableView.reloadData()
    }
    
    
    func eventsForDate(date:Date) -> [Event]
    {
        var daysEvent = [Event]()
        for event in eventsList {
            let eventDate = CalendarHelper.dateFormatter.date(from: event.date)
            let eventInvite = event.invite
            if(Calendar.current.isDate(eventDate!, inSameDayAs: date) && eventInvite == false)
            {
                daysEvent.append(event)
            }
        }
        return daysEvent
    }
    
    func listenForEvent(){
        
        DatabaseManager.shared.getAllEvents(completion: { [weak self] result in
            switch result{
            case .success(let eventsList):
                print("successFully got event models")
                guard !eventsList.isEmpty else{
                    return
                }
                self?.eventsList = eventsList
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to get events \(error)")
                self?.eventsList.removeAll()
                self?.tableView.reloadData()
                self?.noEvents.alpha = 1
            }
        })
    }
    
    //setting the collectionviews styling elements for the boxes
    func setCellView(){
        let width = (collectionView.frame.size.width - 2)/9
        let height = (collectionView.frame.size.height - 50)

        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    
    //Sets up the complete week view of the schedule
    func setWeekView(){
        totalSquares.removeAll()
        
        var current = CalendarHelper().mondayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        
        while (current < nextSunday)
        {
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
        tableView.reloadData()
    }
    
    //When Previous week button clicked -7 days from current days selection and recall function
    @IBAction func previousWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
        setWeekView()
    }
    //When next week button clicked +7 days from current days selection and recall function
    @IBAction func nextWeek(_ sender: Any) {
        selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
        setWeekView()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
            super.viewDidAppear(animated)
            tableView.reloadData()
    }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //Counting number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        //setting the date to the individual squares
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        //setting the background colour to blue if its the current date
        if(date == selectedDate){
            cell.backgroundColor = UIColor.systemBlue
        }
        else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    //when date on collectionview is selected reload data
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = totalSquares[indexPath.item]
        collectionView.reloadData()
        tableView.reloadData()
    }
   
    
    
}


///Extension for the table section of the Home page where events are shown
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            
            //Add db call
        if(eventsForDate(date: selectedDate).count != 0){
            noEvents.alpha = 0
        }
        //getting number of events
        return eventsForDate(date: selectedDate).count
        
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //creating a reusable cell that can add multiple events from eventsForDate
        let model = eventsForDate(date: selectedDate)[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: scheduledEventViewCell.identifier, for: indexPath) as! scheduledEventViewCell
        cell.configure(with: model)
        //let date = CalendarHelper.dateFormatter.date(from: event.date)
        //cell.textLabel?.text = event.name + " " + event.date
    
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
            guard let invitedUser = eventsList[indexPath.row].inviteWith else {return}
            guard let user = eventsList[indexPath.row].from else {return}
            let currentEmail =  DatabaseManager.safeEmail(email: UserDefaults.standard.value(forKey: "email") as! String)
            guard let eventId = eventsList[indexPath.row].eventId else { return }
            tableView.beginUpdates()
            self.eventsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
            if(invitedUser == "none"){
            
                DatabaseManager.shared.deleteEvent(email: user, eventId: eventId, completion: { success in
                    if !success { print("delete failed")}
                })
            }
            else{
                
                DatabaseManager.shared.deleteEvent(email: invitedUser, eventId: eventId, completion: { success in
                    if !success { print("delete failed")}
                })
                DatabaseManager.shared.deleteEvent(email: currentEmail, eventId: eventId, completion: { success in
                    if !success { print("delete failed")}
                })
                
            }
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
}
