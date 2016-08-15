//
//  Event.swift
//  MicCheck
//
//  Created by Eric Nash on 10/27/15.
//  Copyright © 2015 Eric Nash Designs. All rights reserved.
//

import Foundation
import Kanna
import SwiftyJSON

class LineUp {
    
    static let sharedInstance = LineUp()

    let testMode: Bool = false
    
    var events: [Event] = []

    private init() {
        self.loadVenuesFromJSON()
        

    }
    
    func loadVenuesFromJSON() {

        // MARK: Create Array of Event objects from events.json
        
        if let path = NSBundle.mainBundle().pathForResource("events", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                
                if let lineup = json["events"].array {
                    
//                    print(" Event.swift - loadVenuesFromJSON() - start")
//                    print(" = = = = = = = = = = = =")
                    
                    
                    eventLoop: for currentEvent in lineup {
                        
                        let eventDictionary: NSDictionary = currentEvent.object as! NSDictionary
                        
                        let event = Event(Dictionary: eventDictionary)
//                        print(" \(event.venue!)")
                        //                        print(event.urlEvent)

                        event.eventHappeningTonight = true
                        
                        
                            //                            print(" Event.swift - populating currentEvent in lineup")

                        event.urlEvent = event.testUrlEvent!
                        event.artist = event.testArtist!
//                        print(" \(event.artist)")
                        event.imgArtist = UIImage(named: event.testImgArtist!)
                        event.price = event.testPrice!
                        
                        print(" \(event.price!)")
                        print(" \(event.urlEvent)")
                        //event.getVideosForArtist()
                        
//                        print("   Event.swift - right after getVideosForArtist the \(event.artist) count is still \(event.vIDItems.count)")
                        //                            let videoDetails = event.vIDItems[currentEvent.int!]
                        //                            viewVideoTopLeft.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (videoDetails["thumbnail"] as? String)!)!)!)
                        print(" = = = = = = = =")
                            

                        
//                        print(" \(event.price!)")
//                        print(" \(event.urlEvent)")
                        //event.getVideosForArtist()
                        
                        //print(" Event.swift - right after getVideosForArtist the \(event.artist) count is still \(event.vIDItems.count)")
                        //                            let videoDetails = event.vIDItems[currentEvent.int!]
                        //                            viewVideoTopLeft.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (videoDetails["thumbnail"] as? String)!)!)!)
//                        print(" = = = = = = = =")
                        events.append(event)
                        
                    }
                    
                } else {
                    print(" could not create lineup array from data")
                }
                
            } else {
                print(" could not create data from path")
            }
        } else {
            print(" could not create path")
        }

//        print(" Event.swift - loadVenuesFromJSON() - end")
    }

    func checkVenueForEventToday() {
        // use the Venue URL in the JSON File to access the venue website and populate other areas
    }
    
    

    func filterTodaysEvents() {

        print(" = = = = = = = = = = = =\r\n")
        
        print(" Event.swift - filterTodaysEvents() - start")

        
        // ERic: since I'm removing items, the idea is to go in reverse so that indexes won't shift
        eventLoop: for (index, currentEvent) in self.events.enumerate().reverse() {

            print(" \(currentEvent.venue!)")
            print(" \(currentEvent.artist)")
            
            // use the Venue URL in the JSON File to access the venue website and populate other areas
            let venueURLString = currentEvent.urlVenue
            let venueURL = NSURL(string: venueURLString!)
            var venueHTMLString: String?
            do {
                venueHTMLString = try String(contentsOfURL: venueURL!, encoding: NSUTF8StringEncoding)
            } catch {
                venueHTMLString = nil
            }
            
            if let doc = Kanna.HTML(html: venueHTMLString!, encoding: NSUTF8StringEncoding) {
                // println(doc.title)
                
                //                                dispatch_async(dispatch_get_main_queue(), {
                //                                    print(" Event.swift - Kanna is finished parsing the venue website: \(event.urlVenue!)")
                //                                    return
                //                                })
                
                // Add Date to the Event, determine if the event is today, and if so, add it to events array
                var nodes = doc.xpath(currentEvent.xPathDate!)
                if (nodes.count > 0) { // make sure there is an image
                    for node in nodes {
                        
                        //print(" Event.swift - original node text = \(node.text!)")
                        
                        // pull out the components from the string and make them a parsed date
                        var trimmedStrEventDate = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        trimmedStrEventDate = trimmedStrEventDate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        
                        print(" Event.swift - Trim Date : \(trimmedStrEventDate)")
                        
                        let eventDateFormatter = NSDateFormatter()
                        eventDateFormatter.dateFormat = currentEvent.dateFormat
                        eventDateFormatter.dateFromString(trimmedStrEventDate)
                        var parsedDate = eventDateFormatter.dateFromString(trimmedStrEventDate) as NSDate!
                        
                        // use the parsed date to create calandar components
                        let calendar = NSCalendar.currentCalendar()
                        let parsedDateComponents = calendar.components([.Day , .Month , .Year], fromDate: parsedDate)
                        
                        // update the calendar components year to the current year
                        let todayDate = NSDate()
                        let todayDateComponents = calendar.components([.Day , .Month , .Year], fromDate: todayDate)
                        parsedDateComponents.year = todayDateComponents.year
                        
                        // reset the parsed date to the same date but with the correct calendar components
                        parsedDate = calendar.dateFromComponents(parsedDateComponents) as NSDate!
                        print(" Event.swift - Event Date: \(eventDateFormatter.stringFromDate(parsedDate))")
                        
                        // if the event date doesn't match up with todays date, just loop to the next event
                        let order = NSCalendar.currentCalendar().compareDate(todayDate, toDate: parsedDate,
                                                                             toUnitGranularity: .Day)
                        switch order {
                        case .OrderedDescending:
                            currentEvent.eventHappeningTonight = false
                            print(" Event.swift - Event already happened, so drop from array")
                            print(" - - - - - - - -")
                        case .OrderedAscending:
                            currentEvent.eventHappeningTonight = false
                            print(" Event.swift - Event will happen on a later day, so drop from array")
                            print(" - - - - - - - -")
                        case .OrderedSame:
                            currentEvent.eventHappeningTonight = true
                            print(" Event.swift - Event happening today. Get event details then add")
                        }
                        
                        
                    }
                } else {
                    currentEvent.artist = "Date Not Available"
                    print(" Could not fetch Date")
                }
                
                print(" - - - - - - - - ")
                print(" Event.swift - currentEvent.eventHappeningTonight = \(currentEvent.eventHappeningTonight)")

                // remove the items that aren't happening tonight
                if (currentEvent.eventHappeningTonight == false) {
                    print(" Event.swift - event not happening so removing \(index)")
                    self.events.removeAtIndex(index)

                } else {  // event is happening, so populate with live stuff

                    // Add Artist Name to the Event
                    nodes = doc.xpath(currentEvent.xPathArtist!)
                    if (nodes.count > 0) { // make sure there was an artist
                        for node in nodes {
                            // remove whitespace characters
                            var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            trimmedString = trimmedString.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                            //                        println(node.text! + " != " + trimmedString)
                            print(" \(trimmedString)")
                            //event.artist = trimmedString.uppercaseString
                            currentEvent.artist = trimmedString
                        }
                    } else {
                        currentEvent.artist = "Artist Not Available"
                        print(" Could not fetch Artist")
                    }
                    
                    
                    
                    // Add URL for Event to the Event
                    nodes = doc.xpath(currentEvent.xPathUrlEvent!)
                    if (nodes.count > 0) { // make sure there was an event url
                        for node in nodes {
                            
                            let event_url = NSURL(string: node.text!)
                            var event_url_string = event_url?.absoluteString
                            let event_data = NSData(contentsOfURL: event_url!)
                            
                            // if URL is fine as is, then go ahead and set it in the event
                            if ((event_data) != nil) {
                                
                                currentEvent.urlEvent = node.text!
                                
                            } else {
                                
                                // add protocol prefix if there double slash has been provided
                                if (event_url_string!.rangeOfString("//") != nil) {
                                    
                                    event_url_string = "http:" + event_url_string!
                                    currentEvent.urlEvent = event_url_string!
                                    
                                    // double slash not provided, so it's relative path and venue website prefix should be added
                                } else {
                                    
                                    currentEvent.urlEvent = currentEvent.urlVenue! + event_url_string!
                                    
                                }
                                
                                // if it still doesn't work then default to event not available
                                if let _ = NSURL(string: currentEvent.urlEvent) {
                                    
                                } else {
                                    currentEvent.urlEvent = "http://www.google.com/#q=" + currentEvent.artist
                                    print(" Could not fetch Event Detail Page")
                                }
                                
                            }
                            
                            print(" \(currentEvent.urlEvent)")
                            
                        }
                    } else {
                        currentEvent.urlEvent = "http://www.google.com/#q=" + currentEvent.artist
                        print(" Could not fetch Event Detail Page")
                    }
                    
                    
                    
                    // Add Artist Image to the Event
                    nodes = doc.xpath(currentEvent.xPathImgArtist!)
                    if (nodes.count > 0) { // make sure there is an image
                        for node in nodes {
                            //print(node.text!)
                            
                            
                            var image_url = NSURL(string: node.text!)
                            var image_url_string = image_url?.absoluteString
                            var image_data = NSData(contentsOfURL: image_url!)
                            if ((image_data) != nil) {
                                let image = UIImage(data: image_data!)
                                currentEvent.imgArtist = image!
                            } else  {
                                
                                // add protocol prefix if there double slash has been provided
                                if (image_url_string!.rangeOfString("//") != nil) {
                                    image_url_string = "http:" + image_url_string!
                                    image_url = NSURL(string: image_url_string!)
                                    image_data = NSData(contentsOfURL: image_url!)
                                    
                                    // double slash not provided, so it's relative path and venue website prefix should be added
                                } else {
                                    
                                    let image_url_string_full = currentEvent.urlVenue
                                    let part_to_clip = image_url_string_full!.rangeOfString("/", options: .BackwardsSearch)?.startIndex
                                    let image_url_string_remainder = image_url_string_full!.substringToIndex(part_to_clip!)
                                    
                                    image_url_string = image_url_string_remainder + "/" + image_url_string!
                                    image_url = NSURL(string: image_url_string!)
                                    image_data = NSData(contentsOfURL: image_url!)
                                }
                                
                                
                                // get larger version of image if a small one has been provided
                                if (image_url_string!.rangeOfString("atsm.") != nil) {
                                    image_url_string = image_url_string!.stringByReplacingOccurrencesOfString("atsm.", withString: "atlg.", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                    image_url = NSURL(string: image_url_string!)
                                    image_data = NSData(contentsOfURL: image_url!)
                                }
                                
                                
                                // if event URL is facebook, then go scrape that page for the better image
                                if currentEvent.urlEvent.rangeOfString("facebook.com") != nil {
                                    
                                    print(" there is a facebook pic for \(currentEvent.urlEvent)")
                                    
                                    
                                }
                                
                                if ((image_data) != nil) {
                                    let image = UIImage(data: image_data!)
                                    currentEvent.imgArtist = image!
                                } else {
                                    // if it still doesn't work then default to image not available
                                    currentEvent.imgArtist = UIImage(named: "image.not.available")!
                                }
                                
                            }
                            
                            print(" \(image_url_string!)")
                            //print("the image is \(event.imgArtist?.size.width) x \(event.imgArtist?.size.height)")
                            
                        }
                    } else {
                        currentEvent.imgArtist = UIImage(named: "image.not.available")!
                        print(" Could not fetch Artist Image")
                    }
                    
                    
                    
                    // Add Price to the Event
                    if (currentEvent.boolPriceShown == "true") {
                        nodes = doc.xpath(currentEvent.xPathPrice!)
                        
                        if (nodes.count > 0) { // make sure there is an image
                            for node in nodes {
                                // remove whitespace characters
                                var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                trimmedString = trimmedString.stringByReplacingOccurrencesOfString("Tickets ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                
                                trimmedString = trimmedString.stringByReplacingOccurrencesOfString(".00", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                
                                if trimmedString.rangeOfString("$") == nil{
                                    //trimmedString = "Price Not Given"
                                }
                                
                                print(" \(trimmedString)")
                                currentEvent.price = trimmedString
                            }
                        } else {
                            currentEvent.price = ""
                            print(" Could not fetch Price")
                        }
                        
                    } else {
                        currentEvent.price = ""
                        print(" Price not shown on this site")
                    }
                    
                    
                    
                    
                    // Add Videos for Artist
                    //event.getVideosForArtist()
                    
                    

                    
                    
                }
                print(" - - - - - - - - ")
                
            }
            
            

            
        }

        print(" Event.swift - filterTodaysEvents() - end with \(self.events.count) items")
    
    }
    
    
    func other() {

        // MARK: Create Array of Event objects from events.json
        
        if let path = NSBundle.mainBundle().pathForResource("events", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                
                if let lineup = json["events"].array {
                    
                    print(" Event.swift - loadEventsFromFile() - start")
                    print(" = = = = = = = = = = = =")
                    
                    
                    eventLoop: for currentEvent in lineup {
                        
                        let eventDictionary: NSDictionary = currentEvent.object as! NSDictionary
                        
                        let event = Event(Dictionary: eventDictionary)
                        print(" \(event.venue!)")
                        //                        print(event.urlEvent)
                        
                        // just populate everything from events.json file
                        if (testMode == true) {
                            
                            //                            print(" Event.swift - populating currentEvent in lineup")
                            
                            event.eventHappeningTonight = true
                            event.urlEvent = event.testUrlEvent!
                            event.artist = event.testArtist!
                            print(" \(event.artist)")
                            
                            event.imgArtist = UIImage(named: event.testImgArtist!)
                            event.price = event.testPrice!
                            
                            print(" \(event.price!)")
                            print(" \(event.urlEvent)")
                            //event.getVideosForArtist()
                            
                            print("   Event.swift - right after getVideosForArtist the \(event.artist) count is still \(event.vIDItems.count)")
                            //                            let videoDetails = event.vIDItems[currentEvent.int!]
                            //                            viewVideoTopLeft.image = UIImage(data: NSData(contentsOfURL: NSURL(string: (videoDetails["thumbnail"] as? String)!)!)!)
                            print(" = = = = = = = =")
                            
                        } else {     // testMode == false
                            
                            // use the Venue URL in the JSON File to access the venue website and populate other areas
                            let venueURLString = event.urlVenue
                            let venueURL = NSURL(string: venueURLString!)
                            var venueHTMLString: String?
                            do {
                                venueHTMLString = try String(contentsOfURL: venueURL!, encoding: NSUTF8StringEncoding)
                            } catch {
                                venueHTMLString = nil
                            }
                            
                            if let doc = Kanna.HTML(html: venueHTMLString!, encoding: NSUTF8StringEncoding) {
                                // println(doc.title)

//                                dispatch_async(dispatch_get_main_queue(), {
//                                    print(" Event.swift - Kanna is finished parsing the venue website: \(event.urlVenue!)")
//                                    return
//                                })
                                
                                // Add Date to the Event, determine if the event is today, and if so, add it to events array
                                var nodes = doc.xpath(event.xPathDate!)
                                if (nodes.count > 0) { // make sure there is an image
                                    for node in nodes {
                                        
                                        //print(" Event.swift - original node text = \(node.text!)")
                                        
                                        // pull out the components from the string and make them a parsed date
                                        var trimmedStrEventDate = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                        trimmedStrEventDate = trimmedStrEventDate.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                        
                                        print(" Event.swift - trimmed node date = \(trimmedStrEventDate)")
                                        
                                        let eventDateFormatter = NSDateFormatter()
                                        eventDateFormatter.dateFormat = event.dateFormat
                                        eventDateFormatter.dateFromString(trimmedStrEventDate)
                                        var parsedDate = eventDateFormatter.dateFromString(trimmedStrEventDate) as NSDate!
                                        
                                        // use the parsed date to create calandar components
                                        let calendar = NSCalendar.currentCalendar()
                                        let parsedDateComponents = calendar.components([.Day , .Month , .Year], fromDate: parsedDate)
                                        
                                        // update the calendar components year to the current year
                                        let todayDate = NSDate()
                                        let todayDateComponents = calendar.components([.Day , .Month , .Year], fromDate: todayDate)
                                        parsedDateComponents.year = todayDateComponents.year
                                        
                                        // reset the parsed date to the same date but with the correct calendar components
                                        parsedDate = calendar.dateFromComponents(parsedDateComponents) as NSDate!
                                        print(" Event.swift - Event Date: \(eventDateFormatter.stringFromDate(parsedDate))")
                                        
                                        // if the event date doesn't match up with todays date, just loop to the next event
                                        let order = NSCalendar.currentCalendar().compareDate(todayDate, toDate: parsedDate,
                                            toUnitGranularity: .Day)
                                        switch order {
                                        case .OrderedDescending:
                                            print(" Event.swift - Event already happened, so drop from array")
                                            print(" - - - - - - - -")
                                            continue eventLoop
                                        case .OrderedAscending:
                                            print(" Event.swift - Event will happen on a later day, so drop from array")
                                            print(" - - - - - - - -")
                                            continue eventLoop
                                        case .OrderedSame:
                                            event.eventHappeningTonight = true
                                            print(" Event.swift - Event happening today. Get event details then add")
                                        }
                                        
                                        
                                    }
                                } else {
                                    event.artist = "Date Not Available"
                                    print(" Could not fetch Date")
                                }
                                
                                
                                
                                // Add Artist Name to the Event
                                nodes = doc.xpath(event.xPathArtist!)
                                if (nodes.count > 0) { // make sure there was an artist
                                    for node in nodes {
                                        // remove whitespace characters
                                        var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\r\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                        trimmedString = trimmedString.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                        //                        println(node.text! + " != " + trimmedString)
                                        print(" \(trimmedString)")
                                        //event.artist = trimmedString.uppercaseString
                                        event.artist = trimmedString
                                    }
                                } else {
                                    event.artist = "Artist Not Available"
                                    print(" Could not fetch Artist")
                                }
                                
                                
                                
                                // Add URL for Event to the Event
                                nodes = doc.xpath(event.xPathUrlEvent!)
                                if (nodes.count > 0) { // make sure there was an event url
                                    for node in nodes {
                                        
                                        let event_url = NSURL(string: node.text!)
                                        var event_url_string = event_url?.absoluteString
                                        let event_data = NSData(contentsOfURL: event_url!)
                                        
                                        // if URL is fine as is, then go ahead and set it in the event
                                        if ((event_data) != nil) {
                                            
                                            event.urlEvent = node.text!
                                            
                                        } else {
                                            
                                            // add protocol prefix if there double slash has been provided
                                            if (event_url_string!.rangeOfString("//") != nil) {
                                                
                                                event_url_string = "http:" + event_url_string!
                                                event.urlEvent = event_url_string!
                                                
                                                // double slash not provided, so it's relative path and venue website prefix should be added
                                            } else {
                                                
                                                event.urlEvent = event.urlVenue! + event_url_string!
                                                
                                            }
                                            
                                            // if it still doesn't work then default to event not available
                                            if let _ = NSURL(string: event.urlEvent) {
                                                
                                            } else {
                                                event.urlEvent = "http://www.google.com/#q=" + event.artist
                                                print(" Could not fetch Event Detail Page")
                                            }
                                            
                                        }
                                        
                                        print(" \(event.urlEvent)")
                                        
                                    }
                                } else {
                                    event.urlEvent = "http://www.google.com/#q=" + event.artist
                                    print(" Could not fetch Event Detail Page")
                                }
                                
                                
                                
                                // Add Artist Image to the Event
                                nodes = doc.xpath(event.xPathImgArtist!)
                                if (nodes.count > 0) { // make sure there is an image
                                    for node in nodes {
                                        //print(node.text!)
                                        
                                        
                                        var image_url = NSURL(string: node.text!)
                                        var image_url_string = image_url?.absoluteString
                                        var image_data = NSData(contentsOfURL: image_url!)
                                        if ((image_data) != nil) {
                                            let image = UIImage(data: image_data!)
                                            event.imgArtist = image!
                                        } else  {
                                            
                                            // add protocol prefix if there double slash has been provided
                                            if (image_url_string!.rangeOfString("//") != nil) {
                                                image_url_string = "http:" + image_url_string!
                                                image_url = NSURL(string: image_url_string!)
                                                image_data = NSData(contentsOfURL: image_url!)
                                                
                                                // double slash not provided, so it's relative path and venue website prefix should be added
                                            } else {
                                                
                                                let image_url_string_full = event.urlVenue
                                                let part_to_clip = image_url_string_full!.rangeOfString("/", options: .BackwardsSearch)?.startIndex
                                                let image_url_string_remainder = image_url_string_full!.substringToIndex(part_to_clip!)
                                                
                                                image_url_string = image_url_string_remainder + "/" + image_url_string!
                                                image_url = NSURL(string: image_url_string!)
                                                image_data = NSData(contentsOfURL: image_url!)
                                            }
                                            
                                            
                                            // get larger version of image if a small one has been provided
                                            if (image_url_string!.rangeOfString("atsm.") != nil) {
                                                image_url_string = image_url_string!.stringByReplacingOccurrencesOfString("atsm.", withString: "atlg.", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                                image_url = NSURL(string: image_url_string!)
                                                image_data = NSData(contentsOfURL: image_url!)
                                            }
                                            
                                            
                                            // if event URL is facebook, then go scrape that page for the better image
                                            if event.urlEvent.rangeOfString("facebook.com") != nil {
                                                
                                                print(" there is a facebook pic for \(event.urlEvent)")


                                                // I think these Facebook queries are causing the app to crash when running on on the iPhone.
                                                
                                                /*      /html/body/div[1]/div[2]/div[3]/div/div[2]/div[1]/h1/a/@href",
                                                "xPathArtist": "(//div[contains(@class, 'list-view-details')])[1]/h1[contains(@class, 'headliners')]/a[1]",
                                                "xPathImgArtist": "//div[contains(@class, 'list-view-item')][1]/a[1]/img/@src"
                                                */
                                                
//                                                
//                                                let FacebookURLString = event.urlEvent
//                                                let FacebookURL = NSURL(string: FacebookURLString)
//                                                var FacebookHTMLString: String?
//                                                do {
//                                                    FacebookHTMLString = try String(contentsOfURL: FacebookURL!, encoding: NSUTF8StringEncoding)
//                                                } catch {
//                                                    FacebookHTMLString = nil
//                                                }
                                                
                                                //let xPathFaceBookProfilePicSrc: String = "//html/body/div[@class='_li']/div[@id='globalContainer']/div[contains(@class, 'fb_content')]/div/div[@id='mainContainer']/div[@id='contentCol']/div[@id='contentArea']"
                                                
//                                                let xPathFaceBookProfilePicSrc: String = "//*[@id='fbCoverImageContainer']/img[1]"
//                                                
//                                                
//                                                if let FBdoc = Kanna.HTML(html: FacebookHTMLString!, encoding: NSUTF8StringEncoding) {
//                                                    
//                                                    let FBnodes = FBdoc.xpath(xPathFaceBookProfilePicSrc)
//                                                    
//                                                    if (FBnodes.count > 0) { // make sure there is an image
//                                                        print(FBnodes.count)
//                                                        for FBnode in FBnodes {
//                                                            print(" there is a \(FBnode.tagName!) with html \(FBnode.toHTML!)")
//                                                            
//                                                            //                                                            image_url = NSURL(string: FBnode.text!)
//                                                            //                                                            image_data = NSData(contentsOfURL: image_url!)
//                                                            
//                                                        }
//                                                    } else {
//                                                        print(" Could not fetch Facebook Image")
//                                                    }
//                                                    
//                                                }
                                                
                                            }
                                            
                                            if ((image_data) != nil) {
                                                let image = UIImage(data: image_data!)
                                                event.imgArtist = image!
                                            } else {
                                                // if it still doesn't work then default to image not available
                                                event.imgArtist = UIImage(named: "image.not.available")!
                                            }
                                            
                                        }
                                        
                                        print(" \(image_url_string!)")
                                        //print("the image is \(event.imgArtist?.size.width) x \(event.imgArtist?.size.height)")
                                        
                                    }
                                } else {
                                    event.imgArtist = UIImage(named: "image.not.available")!
                                    print(" Could not fetch Artist Image")
                                }
                                
                                
                                
                                // Add Price to the Event
                                if (event.boolPriceShown == "true") {
                                    nodes = doc.xpath(event.xPathPrice!)
                                    
                                    if (nodes.count > 0) { // make sure there is an image
                                        for node in nodes {
                                            // remove whitespace characters
                                            var trimmedString = node.text!.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                                            trimmedString = trimmedString.stringByReplacingOccurrencesOfString("Tickets ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                            
                                            trimmedString = trimmedString.stringByReplacingOccurrencesOfString(".00", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                            
                                            if trimmedString.rangeOfString("$") == nil{
                                                //trimmedString = "Price Not Given"
                                            }
                                            
                                            print(" \(trimmedString)")
                                            event.price = trimmedString
                                        }
                                    } else {
                                        event.price = ""
                                        print(" Could not fetch Price")
                                    }
                                    
                                } else {
                                    event.price = ""
                                    print(" Price not shown on this site")
                                }
                                
                                
                                
                                
                                // Add Videos for Artist
                                //event.getVideosForArtist()
                                
                                
                                
                            }
                            
                            print(" - - - - - - - - ")
                            
                        }
                        
                        events.append(event)
                        
                    }
                    
                } else {
                    print(" could not create lineup array from data")
                }
                
            } else {
                print(" could not create data from path")
            }
        } else {
            print(" could not create path")
        }
        
        // if there's no events after going through the sites, then just create a single blank event to display
        if events.count == 0 {
            
            let blankDictionary = ["venue": ""] // venue is immutable, so I cant' set it like the others below
            let event = Event(Dictionary: blankDictionary)
            event.artist = "No Events Today"
            event.imgArtist = UIImage(named: "image.not.available")!
            event.price = ""
            
            events.append(event)
            
        }
        
        print(" = = = = = = = = = = =")
        print(" Event.swift - loadEventsFromFile() - end")

        
        
        print(" Event.swift - the singleton was initialized")
    }
    
}


class Event {
        
    let venue: String?
    let imgVenue: String?
    let urlVenue: String?
    let addressVenue: String?
    let distanceFromVenue: String?
    
    var eventHappeningTonight = false
    var urlEvent = ""
    let xPathUrlEvent: String?
    
    let testUrlEvent: String?
    let testArtist: String?
    let testImgArtist: String?
    let testPrice: String?
    
    var artist = ""
    let xPathArtist: String?
    
    var imgArtist: UIImage?
    let xPathImgArtist: String?
    
    let vIDArtist: String?
    var vIDItems: Array<Dictionary<NSObject, AnyObject>> = []
    
    var price: String?
    let boolPriceShown: String?
    let xPathPrice: String?
    
    let date: String?
    let dateFormat: String?
    let xPathDate: String?
    
    
    init(Dictionary: NSDictionary) {
        
        // These variables will contain the prerequisite data living in events.json
        // With it, I'll scrape the venue website and popoulate the other variables
        
        venue                   = Dictionary["venue"]                   as? String
        imgVenue                = Dictionary["imgVenue"]                as? String
        urlVenue                = Dictionary["urlVenue"]                as? String
        addressVenue            = Dictionary["addressVenue"]            as? String
        distanceFromVenue       = Dictionary["distanceFromVenue"]       as? String
        
        xPathUrlEvent           = Dictionary["xPathUrlEvent"]           as? String
        
        testUrlEvent            = Dictionary["testUrlEvent"]            as? String
        testArtist              = Dictionary["testArtist"]              as? String
        testImgArtist           = Dictionary["testImgArtist"]           as? String
        testPrice               = Dictionary["testPrice"]               as? String
        
        
        xPathArtist             = Dictionary["xPathArtist"]             as? String
        xPathImgArtist          = Dictionary["xPathImgArtist"]          as? String
        vIDArtist               = Dictionary["vIDArtist"]               as? String
        
        
        boolPriceShown          = Dictionary["boolPriceShown"]          as? String
        xPathPrice              = Dictionary["xPathPrice"]              as? String
        date                    = Dictionary["date"]                    as? String
        dateFormat              = Dictionary["dateFormat"]              as? String
        xPathDate               = Dictionary["xPathDate"]               as? String
        
    }
    


    // MARK: YouTube API Functions
    func getVideosForArtist(completion: (() -> Void)!) {
        
        print("   Event.swift - getVideosForArtist start")
        
        let apiKey = "AIzaSyABMIvminGXw9pQ_P1OsKxsO8aaNkvWBak"
        
        // Form the Request URL String
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(self.artist)+music+live&type=video&&maxResults=4&key=\(apiKey)"
        //print(urlString)
        
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        // Create an NSURL Object using the string above
        let targetURL = NSURL(string: urlString)
        
        print("   Event.swift - getVideosForArtst - performGetRequest start for \(self.artist)")
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {  // ensure there’s JSON data by checking HTTP code and error object
                
                // Convert the JSON Data to a Dictionary using the Swift 2.0 error handling system
                do {
                    if let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        //                        print(resultsDict)
                        
                        // Get all search result items ("items" array).
                        let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                                                
                        // Use a loop to go through all video items.
                        for i in 0 ..< items.count {
                            let snippetDict = items[i]["snippet"] as! Dictionary<NSObject, AnyObject>
                            
                            var videoDetailsDict = Dictionary<NSObject, AnyObject>()
                            videoDetailsDict["thumbnail"] = ((snippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["default"] as! Dictionary<NSObject, AnyObject>)["url"]
                            videoDetailsDict["videoID"] = (items[i]["id"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                            
                            // append the desiredPlaylistItemDataDict dictionary to the videos array
                            //tempVIDItems.append(videoDetailsDict)
                            //print("\(self.artist) \(videoDetailsDict["thumbnail"])")
                            self.vIDItems.append(videoDetailsDict)
                            print("   Event.swift - getVideosForArtist() – the videoID for \(self.artist) is \(self.vIDItems[i]["videoID"]!)")
                        }
                        
                        print("   Event.swift – getVideosForArtist() - the videoID count for \(self.artist) is \(self.vIDItems.count)")

                        // run the completion handler specified in DataViewController to load the new videos into the UI
                        completion()
                        
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
            } else {    // HTTP status code is other than 200, or an error has occurred
                print(" HTTP Status Code = \(HTTPStatusCode)")
                print(" Error while loading the channel details \(error)")
                
            }
            
            // Hide the activity indicator.
            //self.viewWait.hidden = true

        })


    
        print("   Event.swift - getVideosForArtst - performGetRequest end for \(self.artist)")
        print("   Event.swift - getVideosForArtist end")
        
    }
    
    // Create the Request
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
        
    }
    
    
}