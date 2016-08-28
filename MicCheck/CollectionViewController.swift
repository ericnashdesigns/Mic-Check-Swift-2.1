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
    var eventsLoaded: Bool = false // keeps track of when everything is loaded
    let cellSpacingsInStoryboard: CGFloat = 2 * 2 // spacing * 2 edges
    var gradientLayerAdded: CALayer?  // reference gradient later when changing size on rotations
    var eventIndex: AnyObject? {  // Retain the index of the selected cell to send over to the pageviewcontroller
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("eventIndex")
        } set {
            NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: "eventIndex")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!  // Reference collectionView in willRotateToInterfaceOrientation
    @IBOutlet var kenBurnsView: JBKenBurnsView!
    @IBOutlet var imgTriangulateAppIcon: UIImageView!
    @IBOutlet var imgMicCheckTitle: UIImageView!
    @IBOutlet var viewActivityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CollectionViewController.swift - viewDidLoad() - start")

        
        // MARK: Create the model with placeholder data
        self.dataSource = ModelController()

        
        // Create the gradient
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
        gradientLayerAdded = self.view.layer.sublayers?.first

        
        // MARK: initiate the loading state, activity indicator and ken burns imaging
        self.viewActivityIndicator.startAnimating()
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

        

        if self.dataSource?.lineUp.testMode == false {

            // MARK: Run an async process to filter out any venues with events not happening today
            // Will return the filtered list once complete
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                
                // filter out the events that aren't happening today
                self.dataSource?.lineUp.filterTodaysEvents()
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // load the view with the filtered data
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
            
            
        } else {  // self.dataSource?.lineUp.testMode == true

            // MARK: Wait 2 seconds and then show all venues in JSON file with test data
            
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
            
        }
        
        
        // MARK: Style the navigation bar

        // Make navigationbar text white
        // You also must add entry "View controller-based status bar appearance" = YES on info.plist
        // to hide status bar on launchscreen you must add "Status bar is initially hidden" = YES on info.plist
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        // Make the navigationbar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        // TODO: Figure out a better way to do this. This is a hack that puts the collectionview under the navigationController
        // if I don't use it, it will place the collectionview too low on the screen.
        self.navigationController?.automaticallyAdjustsScrollViewInsets = false
        self.view.insertSubview(UIView(), atIndex: 0)

        // This is how you can change the Back button text
        //self.navigationItem.backBarButtonItem?.title = "Back"
        
        print("CollectionViewController.swift - viewDidLoad() - end")
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.dataSource?.lineUp.events.count)!
    }

    // MARK: Update the header and footer when events are loaded
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
                
            } else {  // no longer in loading state, so update the venue list and event count
                
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
                
                
                // show the header borders, background colors and image
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
                
                // when there's no events today, a single blank event gets added to the events array
                // with the venue set to "noVenuesToday"
                if dataSource?.lineUp.events[0].venue == "noVenuesToday" {
                    headerView.labelVenueList.text = "No Shows,\r\nThat Blows..."
                }
                
                
                // update the count
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

    
    // MARK: Update the main cells when events are loaded
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        
        if (!eventsLoaded) {
            
            cell.labelArtist.text = ""
            cell.labelVenue.text = ""
            
            
        } else {
            
            //print(" CollectionViewController.swift - cellForItemAtIndexPath - events loaded")
            
            // cell.layer.opacity seemed to give me performance problems when scrolling up and down the list
            //UIView.animateWithDuration(0.5, animations: { cell.layer.opacity = 0 })
            //cell.layer.opacity = 0
            cell.alpha = 0
            
            cell.labelArtist.text = self.dataSource?.lineUp.events[indexPath.row].artist
            if (self.dataSource?.lineUp.events[indexPath.row].venue != "noVenuesToday") {
                cell.labelVenue.text = "@" + (self.dataSource?.lineUp.events[indexPath.row].venue)!
            } else {
                cell.labelVenue.text = ""
            }
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
            
            UIView.animateWithDuration(0.5, animations: { cell.alpha = 1 })
            
        }
        
        return cell
    }
    
    // MARK: Cell Sizing
    // Headers
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 1 header row of 1
            return CGSizeMake((collectionView.frame.size.width - cellSpacingsInStoryboard), (collectionView.frame.size.height)/2)
        }
        else { // portrait mode
            // 1 header row of 1
            return CGSizeMake((collectionView.frame.size.width - cellSpacingsInStoryboard), (collectionView.frame.size.height)/3)
        }
        
    }
    // Main Cells
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 2 rows of 3
            return CGSizeMake((collectionView.frame.size.width)/3 - cellSpacingsInStoryboard, (collectionView.frame.size.height)/2)
        }
        else { // portrait mode
            // 3 rows of 1
            return CGSizeMake((collectionView.frame.size.width - cellSpacingsInStoryboard), (collectionView.frame.size.height)/3)
        }
        
    }
    
    // Footer
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if(orientation == .LandscapeLeft || orientation == .LandscapeRight) {
            // 1 footer row of 1
            return CGSizeMake((collectionView.frame.size.width - cellSpacingsInStoryboard), (collectionView.frame.size.height)/2)
        }
        else { // portrait mode
            // 1 footer row of 1
            return CGSizeMake((collectionView.frame.size.width - cellSpacingsInStoryboard), (collectionView.frame.size.height)/3)
        }
        
    }
    
    // MARK: Prepare the artist images with a fade at the bottom
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

    // Retain the index of the selected cell to send over to the pageviewcontroller
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        eventIndex = indexPath.row
    }
    

    // MARK: Handling device rotations
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // stretch the background gradient in portrait or landscape orientatinos
        gradientLayerAdded!.frame = self.view.bounds

        // invalidateLayout() forces a new sizeForItemAtIndexPath can so that I can correct cell sizes
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
 

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    

}
