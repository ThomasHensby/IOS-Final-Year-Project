//
//  Event.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 14/03/2022.
//

import Foundation
import UIKit

var eventsList = [Event]()

class Event
{
    var id : Int!
    var name : String!
    var date : Date!
    
    func eventsForDate(date:Date) -> [Event]
    {
        var daysEvent = [Event]()
        for event in eventsList {
            if(Calendar.current.isDate(event.date, inSameDayAs: date))
            {
                daysEvent.append(event)
            }
        }
        return daysEvent
    }
}
