//
//  HomeViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 03/01/2022.
//

import UIKit
import MessageKit

var selectedDate = Date()

class HomeViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var menuOut = false
    var selectedDate = Date()
    var totalSquares = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.storyboard?.instantiateViewController(withIdentifier: "mainNav")
        setCellView()
        setWeekView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource
        tableView.delegate
        
        
    }
    //setting selected dates
    func setCellView(){
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.height - 2) / 8
        
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
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            //getting number of events
            Event().eventsForDate(date: selectedDate).count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            //creating a reusable cell that can add multiple events from eventsForDate
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: IndexPath.init())
            let event = Event().eventsForDate(date: selectedDate)[indexPath.row]
            cell.textLabel?.text = event.name + " " + CalendarHelper().timeString(date: event.date)
            return cell
    }
        
    override func viewDidAppear(_ animated: Bool)
    {
            super.viewDidAppear(animated)
            tableView.reloadData()
    }

    

}
