//
//  CollectionViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 4/6/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    var dataSource: ModelController?
    var eventsLoaded: Bool = false // ERic: keeps track of when everything is loaded

    @IBOutlet var collectionView: UICollectionView!  // ERic: I needed this to reference collectionView in willRotateToInterfaceOrientation
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    @IBOutlet var imgTriangulateAppIcon: UIImageView!
    @IBOutlet var imgMicCheckTitle: UIImageView!
    @IBOutlet var viewActivityIndicator: UIActivityIndicatorView!
    
    // ERic: this will retain the index of the selected cell to send over to the pageviewcontroller
    var eventIndex: AnyObject? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("eventIndex")
        } set {
            NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: "eventIndex")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("CollectionViewController.swift - viewDidLoad() - start")
        // Create the model with placeholder data
        self.dataSource = ModelController()
        
        // dark to darker - the one I'm currently using
        let topColor = UIColor(red: (62/255.0), green: (70/255.0), blue: (76/255.0), alpha: 1)
        let bottomColor = UIColor(red: (12/255.0), green: (20/255.0), blue: (26/255.0), alpha: 1)
        
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.frame.origin = CGPointMake(0.0, 0.0)
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)


        self.viewActivityIndicator.startAnimating()
        
        // crank up the ken burns animations
        let images = [
            UIImage(named: "empty.stage")!,
            UIImage(named: "guitarist.mountain.oasis")!,
            UIImage(named: "guitarist.on.stage")!,
            UIImage(named: "edm")!,
            UIImage(named: "jazz.horns")!            
        ]
        
        self.kenBurnsView.alpha = 0
        UIView.animateWithDuration(0.25, animations: {
            self.kenBurnsView.alpha = 1
            }, completion: { finished in
                self.kenBurnsView.animateWithImages(images, imageAnimationDuration: 5, initialDelay: 0, shouldLoop: true, randomFirstImage: true)
        })
        
        
        // This is the one that works, but returns the whole bulk after the fact
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {

            
            if self.dataSource?.lineUp.testMode == true {
                
                // purposefully just build in a 2 second delay
                
                let delayInSeconds = 8.0
                let popTime = dispatch_time(DISPATCH_TIME_NOW,
                                            Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue()) {

                    self.eventsLoaded = true
                    self.collectionView.reloadData()
                    
                    // hide the ken burns images, app art, and activity indicator
                    UIView.animateWithDuration(0.5, animations: {
                        self.viewActivityIndicator.alpha = 0
                        self.kenBurnsView.alpha = 0
                        self.imgTriangulateAppIcon.alpha = 0
                        self.imgMicCheckTitle.alpha = 0
                        
                        }, completion: { finished in
                            self.viewActivityIndicator.stopAnimating()
                            self.viewActivityIndicator.hidden = true
                            self.kenBurnsView.stopAnimation()
                            self.kenBurnsView.hidden = true
                            self.imgTriangulateAppIcon.hidden = true
                            self.imgMicCheckTitle.hidden = true
                            
                    })
                    
                    print("CollectionViewController.swift - data was reloaded")
                    
                    
                }
            } else {
            
            
            // filter out the events that aren't happening today
            self.dataSource?.lineUp.filterTodaysEvents()

            dispatch_async(dispatch_get_main_queue()) {

                // update some UI
                self.eventsLoaded = true
                self.collectionView.reloadData()

                // hide the ken burns images, app art, and activity indicator
                UIView.animateWithDuration(0.5, animations: {
                    self.viewActivityIndicator.alpha = 0
                    self.kenBurnsView.alpha = 0
                    self.imgTriangulateAppIcon.alpha = 0
                    self.imgMicCheckTitle.alpha = 0

                    }, completion: { finished in
                        self.viewActivityIndicator.stopAnimating()
                        self.viewActivityIndicator.hidden = true
                        self.kenBurnsView.stopAnimation()
                        self.kenBurnsView.hidden = true
                        self.imgTriangulateAppIcon.hidden = true
                        self.imgMicCheckTitle.hidden = true

                })
                
                print("CollectionViewController.swift - data was reloaded")
                
            }
            }
        }

        // hide the navigation bar
//        self.navigationController?.navigationBarHidden = true

        // make the navigation bar text white
        // You also must add entry "View controller-based status bar appearance" = YES on info.plist
        // to hide status bar on launchscreen you must add "Status bar is initially hidden" = YES on info.plist
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        
        // CollectionViewController.swift - viewDidLoad() - this makes the navigationbar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        // TODO: Figure out a better way to do this
        // CollectionViewController.swift - viewDidLoad() - this is a hack that puts the view under the navigationController
        // currently, if I don't use it, it will place the collectionview too low on the screen.
        self.navigationController?.automaticallyAdjustsScrollViewInsets = false
        self.view.insertSubview(UIView(), atIndex: 0)

        // This is how you can change the Back button text
        //self.navigationItem.backBarButtonItem?.title = "Back"
        
        print("CollectionViewController.swift - viewDidLoad() - end")
        

        
    }

    func maskImage(cell:CollectionViewCell, image:UIImage, mask:(UIImage))->UIImage{
        
        let imageReference = image.CGImage
        let maskReference = mask.CGImage
        
        let imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),//Int(cell.frame.width),
                                          CGImageGetHeight(maskReference),//Int(cell.frame.height),
                                          CGImageGetBitsPerComponent(maskReference),
                                          CGImageGetBitsPerPixel(maskReference),
                                          CGImageGetBytesPerRow(maskReference),
                                          CGImageGetDataProvider(maskReference), nil, true)
        
        let maskedReference = CGImageCreateWithMask(imageReference, imageMask)
        
        let maskedImage = UIImage(CGImage:maskedReference!)
        
        return maskedImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

            switch kind {

            case UICollectionElementKindSectionHeader:


                let headerView =
                collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                    withReuseIdentifier: "CollectionViewHeader",
                    forIndexPath: indexPath)
                    as! CollectionViewHeader
                
                if (!eventsLoaded) { // header is in loading state
                    
                    
                    // hide the borders and background image until it's time
                    headerView.alpha = 0
                    
                    headerView.labelVenueList.text = ""
                    headerView.labelShowCount.text = ""
                    
                } else {  // update the venue list and event count

                    
                    // update today's date
                    let currentDate = NSDate()
                    let dayFormatter = NSDateFormatter()
                    dayFormatter.dateFormat = "EEE"
                    let convertedDay = dayFormatter.stringFromDate(currentDate).uppercaseString
                    
                    let monthFormatter = NSDateFormatter()
                    monthFormatter.dateFormat = "MMM"
                    let convertedMonth = monthFormatter.stringFromDate(currentDate).uppercaseString
                    
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "d"
                    let convertedDate = dateFormatter.stringFromDate(currentDate).uppercaseString
                    
                    
                    // rotate the date
                    headerView.labelDay.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2)/2)
                    headerView.labelDate.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2)/2)
                    headerView.labelMonth.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2)*1.5)
                    headerView.labelDay.text = convertedDay
                    headerView.labelMonth.text = convertedMonth
                    headerView.labelDate.text = convertedDate
                    
                    
                    // show the header borders, backgorund colors and image
                    UIView.animateWithDuration(0.5, animations: {
                        headerView.alpha = 1
                        
                        headerView.viewLogoBackground.backgroundColor = UIColor(red: (0.95), green: (0.26), blue: (0.21), alpha: 1)
                    })
                    
                    
                    // hide the header labels, clear them out, populate them, then fade them back in
                    headerView.labelShowCount.alpha = 0
                    headerView.labelVenueList.alpha = 0
                    headerView.labelVenueList.numberOfLines = 0
                    headerView.labelVenueList.text = ""
                    var venueCount = 0
                    
                    for currentEvent in (dataSource?.lineUp.events)! {
                        if (currentEvent.eventHappeningTonight) {
                            
                            if venueCount == 6 {
                                headerView.labelVenueList.text = headerView.labelVenueList.text! + "& More"
                                break
                            }
                            
                            headerView.labelVenueList.text = headerView.labelVenueList.text! + currentEvent.venue! + "\r"
                            venueCount += 1
                        }
                    }

                    
                    headerView.labelShowCount.text =  "\(venueCount)"
                    UIView.animateWithDuration(0.5, animations: {
                        headerView.labelVenueList.alpha = 1
                        headerView.labelShowCount.alpha = 1
                    })

                    
                }
                

                return headerView
                

            case UICollectionElementKindSectionFooter:
                let footerView =
                    collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                          withReuseIdentifier: "CollectionViewFooter",
                                                                          forIndexPath: indexPath)
                return footerView
            
            default:
                //4
                assert(false, "Unexpected element kind")
            }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.dataSource?.lineUp.events.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell

        if (!eventsLoaded) {
            
            print(" CollectionViewController.swift - cellForItemAtIndexPath - events not yet loaded")
        
            cell.labelArtist.text = ""
            cell.labelVenue.text = ""
            
        
        } else {
            
            print(" CollectionViewController.swift - cellForItemAtIndexPath - events loaded")
            
//            UIView.animateWithDuration(0.5, animations: { cell.layer.opacity = 0 })
            //cell.layer.opacity = 0
            cell.alpha = 0

            cell.labelArtist.text = self.dataSource?.lineUp.events[indexPath.row].artist
            cell.labelVenue.text = "@" + (self.dataSource?.lineUp.events[indexPath.row].venue)!
            cell.imgArtistView.image = self.dataSource?.lineUp.events[indexPath.row].imgArtist

            cell.imgArtistView.layer.masksToBounds = true
            let maskImage = UIImage(named: "halftonesmall")
            let maskLayer = CALayer()
            maskLayer.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
            maskLayer.contents = maskImage?.CGImage
            cell.imgArtistView.layer.mask = maskLayer

            cell.labelArtist.textColor = UIColor.whiteColor()

            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor(red: (0/255.0), green: (0/255.0), blue: (0/255.0), alpha: 0.25).CGColor
//                let topColor = UIColor(red: (26/255.0), green: (24/255.0), blue: (24/255.0), alpha: 1)
            
            UIView.animateWithDuration(0.5, animations: { cell.alpha = 1 })
            
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        eventIndex = indexPath.row
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
                
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 2 rows of 1
            return CGSizeMake((collectionView.frame.size.width), (collectionView.frame.size.height)/2-2)
        }
        else { // portrait mode
            // 1 row of 3
            return CGSizeMake((collectionView.frame.size.width), (collectionView.frame.size.height)/3-2)
        }

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 2 rows of 1
            return CGSizeMake((collectionView.frame.size.width), (collectionView.frame.size.height)/2-2)
        }
        else { // portrait mode
            // 1 row of 3
            return CGSizeMake((collectionView.frame.size.width), (collectionView.frame.size.height)/3-2)
        }

        
    }
    
 
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 2 rows of 3
            return CGSizeMake((collectionView.frame.size.width)/3, (collectionView.frame.size.height)/2)
        }
        else { // portrait mode
            // 3 rows of 1
            
//            if indexPath.row > 0 {
                return CGSizeMake((collectionView.frame.size.width), (collectionView.frame.size.height)/3)
            //} //else { // special case the first row to fill the width
                //return CGSizeMake(collectionView.frame.size.width - 16, CGFloat(collectionView.frame.size.height)/3 - 4)
            //}
                //return CGSizeMake(collectionView.frame.size.width - 8, CGFloat(collectionView.frame.size.height)/3 - 4)
         
        }
        
    }
    

    // this ensures that the gradient sublayer I created in viewDidLoad stretches when in landscape
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.view.layer.sublayers?.first?.frame = self.view.bounds
    }
    
    // ERic: invalidateLayout() forces a new sizeForItemAtIndexPath can so that I can correct the cell size for each layout
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    

    
    // hide the wifi connection, clock, and battery level
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }

    

}
