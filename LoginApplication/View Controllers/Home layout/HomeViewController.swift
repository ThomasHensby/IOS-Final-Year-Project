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
        setCellView()
        setWeekView()
        tableView.register(scheduledEventViewCell.self, forCellReuseIdentifier: scheduledEventViewCell.identifier)
        listenForEvent()
    }
    
    
    
    func eventsForDate(date:Date) -> [Event]
    {
        var daysEvent = [Event]()
        for event in eventsList {
            let eventDate = CalendarHelper.dateFormatter.date(from: event.date)
            if(Calendar.current.isDate(eventDate!, inSameDayAs: date))
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
            }
        })
    }
            
            
    
    //setting selected dates
    func setCellView(){
        let width = (collectionView.frame.size.width)/8
        let height = (collectionView.frame.size.height) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    //Counting number of items
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarCell
        
        let date = totalSquares[indexPath.item]
        cell.dayOfMonth.text = String(CalendarHelper().dayOfMonth(date: date))
        
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
            //getting number of events
            eventsForDate(date: selectedDate).count
            //Add db call
        
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
    
}
