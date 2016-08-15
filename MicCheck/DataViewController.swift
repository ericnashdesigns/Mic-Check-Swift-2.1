//
//  DataViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 10/27/15.
//  Copyright © 2015 Eric Nash Designs. All rights reserved.
//

import UIKit
import QuartzCore
import youtube_ios_player_helper

class DataViewController: UIViewController {

    let lineUp = LineUp.sharedInstance
    
    @IBOutlet weak var dataDayLabel: UILabel!
    @IBOutlet weak var dataMonthLabel: UILabel!
    @IBOutlet weak var dataDateLabel: UILabel!
    @IBOutlet weak var dataIndexOfCountLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var dataVenueLabel: UILabel!
    @IBOutlet weak var dataPriceLabel: UILabel!
    @IBOutlet weak var imgArtist: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var floatButton1: MKButton!
    @IBOutlet weak var viewPrimaryColorLabel: UILabel!
    @IBOutlet weak var viewPrimaryColor: UIView!
    @IBOutlet weak var viewPrimaryColorInverse: UIView!
    @IBOutlet weak var viewSecondaryColorLabel: UILabel!
    @IBOutlet weak var viewSecondaryColor: UIView!
    @IBOutlet weak var viewSecondaryColorInverse: UIView!
    @IBOutlet weak var viewDetailColorLabel: UILabel!
    @IBOutlet weak var viewDetailColor: UIView!
    @IBOutlet weak var viewDetailColorInverse: UIView!
    @IBOutlet weak var viewBackgroundColorLabel: UILabel!
    @IBOutlet weak var viewBackgroundColor: UIView!
    @IBOutlet weak var viewBackgroundColorInverse: UIView!
    @IBOutlet var viewVideoPlayerTopLeft: YTPlayerView!
    @IBOutlet var viewVideoPlayerTopRight: YTPlayerView!
    @IBOutlet var viewVideoPlayerBottomLeft: YTPlayerView!
    @IBOutlet var viewVideoPlayerBottomRight: YTPlayerView!
    @IBOutlet var labelNoVideosFound: UILabel!
    @IBOutlet var labelIndexOfCount: UILabel!
    
    
    // variables just for holding data.  Actual values are set in ModelController.swift
    var dataIntEventIndex: Int = 0
    var dataIntEventCount: Int = 0
    var swipeDirection: String = ""
    var dataVenue: String = ""
    var dataURLEvent: String = ""
    var dataObject: String = ""
    var dataImgArtist: UIImage!
    var dataPrice: String = ""
    var dataVIDItems: Array<Dictionary<NSObject, AnyObject>> = []
    //    var dataEvent = Event(Dictionary: eventDictionary)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // You should do things that you only have to do once in viewDidLoad
        
        
        // This was the first step so that I could write the didChangeToState function
//        self.viewVideoPlayerTopLeft.delegate = self
//        self.viewVideoPlayerTopRight.delegate = self
//        self.viewVideoPlayerBottomLeft.delegate = self
//        self.viewVideoPlayerBottomRight.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // if you're going to get rid of this, also get rid of the delegate stuff
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState)
    {
        switch state {
            case .Queued:
                print("*********************************************************************************")
                print("  DataViewController.swift - didChangeToState() - Player just changed to Queued")
                break
            case .Unstarted:
                print("*********************************************************************************")
                print("  DataViewController.swift - didChangeToState() - Player just changed to Unstarted")
                break
            default:
                break
            }
    }

    
    override func viewWillAppear(animated: Bool) {

        print("  DataViewController.swift - ViewWIllAppear() started")
        
        super.viewWillAppear(animated)
        
        // update todays date
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
        
        dataMonthLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        dataDayLabel.text = convertedDay
        dataMonthLabel.text = convertedMonth
        dataDateLabel.text = convertedDate
        
       
        // update the text fields
        self.dataIndexOfCountLabel.text = "\(dataIntEventIndex) of \(dataIntEventCount)"
        self.dataLabel!.text = dataObject
        self.dataVenueLabel!.text = dataVenue
        self.dataPriceLabel!.text = dataPrice

        
        // mask the image
        let maskImage = UIImage(named: "halftone")  // this has the same square dimensions is imgArtist 325x325pt
        let maskLayer = CALayer()
        maskLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 400)
        maskLayer.contents = maskImage?.CGImage
        self.imgArtist.layer.mask = maskLayer
        self.imgArtist.image =  dataImgArtist
        
        
        self.imgArtist.alpha = 0
        UIView.animateWithDuration(0.25, delay: 0, options: [], animations: {
            self.imgArtist.alpha = 1
        }, completion: nil)


        // get the button ready
        floatButton1.maskEnabled = false
        floatButton1.ripplePercent = 1.75
        floatButton1.rippleLocation = .Center
        
        floatButton1.layer.shadowOpacity = 0.25
        floatButton1.layer.shadowRadius = 3.5
        floatButton1.layer.shadowColor = UIColor.blackColor().CGColor
        floatButton1.layer.shadowOffset = CGSize(width: 1.0, height: 1)
        
        // attach the videos
        if self.lineUp.events[self.dataIntEventIndex - 1].vIDItems.isEmpty {
            
            print("  DataViewController.swift - viewWillAppear() - self.lineUp.events[self.dataIntEventIndex - 1].vIDItems is empty")
            
            
            // get the videos for the artist and load them into the model
            self.lineUp.events[self.dataIntEventIndex - 1].getVideosForArtist({ Void in
                
                // callback to load the videos into the DataViewController and update the UI
                print("  DataViewController.swift - ViewWillAppear() - callback executing")
                self.dataVIDItems = self.lineUp.events[self.dataIntEventIndex - 1].vIDItems
                self.loadVideoThumbs()
            })
            
            
        } else {   // vIDItems in Model are already there so just assign them to the DataViewController and update the UI
            
            print("  DataViewController.swift - viewWillAppear() - self.lineUp.events[self.dataIntEventIndex - 1].vIDItems array is Not Empty, so load what's there")
            
            self.dataVIDItems = self.lineUp.events[self.dataIntEventIndex - 1].vIDItems
            self.loadVideoThumbs()
            
        }
        
        
        // assign colors
        let colors = dataImgArtist.getColors()
        
        self.navigationController!.navigationBar.tintColor = colors.secondaryColor;
        
        viewContainer.backgroundColor = colors.backgroundColor

        floatButton1.setTitleColor(colors.secondaryColor, forState: .Normal)
        
        dataIndexOfCountLabel.textColor = colors.detailColor
        dataDayLabel.textColor = colors.secondaryColor
        dataDayLabel.layer.shadowRadius = 4.0
        dataDayLabel.layer.shadowOpacity = 0.9
        dataDayLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataDayLabel.layer.shadowOffset = CGSizeZero
        dataDayLabel.layer.masksToBounds = false

        dataMonthLabel.textColor = colors.detailColor
        dataMonthLabel.layer.shadowRadius = 4.0
        dataMonthLabel.layer.shadowOpacity = 0.9
        dataMonthLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataMonthLabel.layer.shadowOffset = CGSizeZero
        dataMonthLabel.layer.masksToBounds = false

        dataDateLabel.textColor = colors.detailColor
        dataDateLabel.layer.shadowRadius = 4.0
        dataDateLabel.layer.shadowOpacity = 0.9
        dataDateLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataDateLabel.layer.shadowOffset = CGSizeZero
        dataDateLabel.layer.masksToBounds = false

        
        dataLabel.textColor = colors.secondaryColor
        dataLabel.shadowColor = colors.backgroundColor
        dataLabel.shadowOffset = CGSize(width: 0, height: 0)
        dataLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataLabel.layer.shadowRadius = 4.0
        dataLabel.layer.shadowOpacity = 1
        dataLabel.layer.shadowOffset = CGSizeZero
        dataLabel.layer.masksToBounds = false


//        print("Background Color: \(colors.backgroundColor.hashValue)")
//        print("Primary Color: \(colors.primaryColor.hashValue)")
//        print("Secondary Color: \(colors.secondaryColor.hashValue)")
//        print("Detail Color: \(colors.detailColor.hashValue)")
        
        dataVenueLabel.textColor = colors.detailColor
        dataVenueLabel.layer.shadowRadius = 4.0
        dataVenueLabel.layer.shadowOpacity = 0.9
        dataVenueLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataVenueLabel.layer.shadowOffset = CGSizeZero
        dataLabel.layer.masksToBounds = false

        
        dataPriceLabel.textColor = colors.detailColor
        dataPriceLabel.layer.shadowRadius = 4.0
        dataPriceLabel.layer.shadowOpacity = 0.9
        dataPriceLabel.layer.shadowColor = colors.backgroundColor.CGColor
        dataPriceLabel.layer.shadowOffset = CGSizeZero

        
        let videoPlayerRadius: CGFloat = 5
        viewVideoPlayerTopLeft.backgroundColor = colors.backgroundColor
        viewVideoPlayerTopLeft.layer.cornerRadius = videoPlayerRadius
        viewVideoPlayerTopLeft.layer.masksToBounds = true
        
        viewVideoPlayerTopRight.backgroundColor = colors.backgroundColor
        viewVideoPlayerTopRight.layer.cornerRadius = videoPlayerRadius
        viewVideoPlayerTopRight.layer.masksToBounds = true
        
        viewVideoPlayerBottomLeft.backgroundColor = colors.backgroundColor
        viewVideoPlayerBottomLeft.layer.cornerRadius = videoPlayerRadius
        viewVideoPlayerBottomLeft.layer.masksToBounds = true
        
        viewVideoPlayerBottomRight.backgroundColor = colors.backgroundColor
        viewVideoPlayerBottomRight.layer.cornerRadius = videoPlayerRadius
        viewVideoPlayerBottomRight.layer.masksToBounds = true

        

        labelNoVideosFound.textColor = colors.secondaryColor.colorWithAlphaComponent(0.5)
        
        viewPrimaryColorLabel.textColor = colors.backgroundColor.inverse()
        viewPrimaryColor.backgroundColor = colors.primaryColor
        viewPrimaryColorInverse.backgroundColor = colors.primaryColor.inverse()
        
        viewSecondaryColorLabel.textColor = colors.backgroundColor.inverse()
        viewSecondaryColor.backgroundColor = colors.secondaryColor
        viewSecondaryColorInverse.backgroundColor = colors.secondaryColor.inverse()
        
        viewDetailColorLabel.textColor = colors.backgroundColor.inverse()
        viewDetailColor.backgroundColor = colors.detailColor
        viewDetailColorInverse.backgroundColor = colors.detailColor.inverse()
        
        viewBackgroundColorLabel.textColor = colors.backgroundColor.inverse()
        viewBackgroundColor.backgroundColor = colors.backgroundColor
        viewBackgroundColorInverse.backgroundColor = colors.backgroundColor.inverse()
        
        
        self.dataLabel.alpha = 0
        self.dataVenueLabel.alpha = 0
        self.dataPriceLabel.alpha = 0
        
        let labelAnimationOffsetBegin: CGFloat = 100

        print("  DataViewController.swift - ViewWillAppear() - self.swipeDirection = \(self.swipeDirection)")
        
        if self.swipeDirection == "up" {
            
            UIView.animateWithDuration(0.5, delay: 0, options: [], animations: {
                self.dataLabel.center.y += labelAnimationOffsetBegin
                self.dataVenueLabel.center.y += labelAnimationOffsetBegin
                self.dataLabel.alpha = 1
                self.dataVenueLabel.alpha = 1
                self.dataPriceLabel.center.y += labelAnimationOffsetBegin
                self.dataPriceLabel.alpha = 1
                
            }, completion: nil)

        } else if self.swipeDirection == "down" {
            UIView.animateWithDuration(0.5, delay: 0, options: [], animations: {
                self.dataLabel.center.y -= labelAnimationOffsetBegin
                self.dataVenueLabel.center.y -= labelAnimationOffsetBegin
                self.dataLabel.alpha = 1
                self.dataVenueLabel.alpha = 1
                self.dataPriceLabel.center.y -= labelAnimationOffsetBegin
                self.dataPriceLabel.alpha = 1
                
                }, completion: nil)
            
        }
        
        
        print("  DataViewController.swift - ViewWIllAppear() end")
        
    }
    
    func loadVideoThumbs() {

        print("  DataViewController.swift - loadVideoThumbs() – self.lineUp.events[self.dataIntEventIndex - 1].vIDItems.count = \(self.lineUp.events[self.dataIntEventIndex - 1].vIDItems.count)")
        
        // load the video thumb parameters
        let playervars: [String: Int] = [
            "controls": 0,
            "showinfo": 0,
            "fs": 0,
            "modestbranding": 1
            
        ]
        
        if self.dataVIDItems.count > 0 && self.dataLabel.text!.rangeOfString("Artist Not Available") == nil && self.dataLabel.text!.lowercaseString.rangeOfString("closed") == nil {
            

            let viewVideoPlayers = [self.viewVideoPlayerTopLeft,
                                    self.viewVideoPlayerTopRight,
                                    self.viewVideoPlayerBottomLeft,
                                    self.viewVideoPlayerBottomRight] 

            // fade them all first
            for currentViewVideoPlayer in viewVideoPlayers {
                currentViewVideoPlayer.layer.opacity = 0
            }
            
            var videoIndex = 0
            
            for currentViewVideoPlayer in viewVideoPlayers {
                
                // check to see if each exists and if so, fade it in
                if self.dataVIDItems.count > videoIndex {
                    
                    let currentVideo = (self.dataVIDItems[videoIndex]["videoID"] as! String)
                    currentViewVideoPlayer.loadWithVideoId(currentVideo, playerVars: playervars)
                    
// This is what I had the spring nonsense
//                    UIView.animateWithDuration(0.25, delay: 1.5, usingSpringWithDamping: 0.3, initialSpringVelocity: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
//                        // do stuff
//                        currentViewVideoPlayer.alpha = 1
//                        currentViewVideoPlayer.transform = CGAffineTransformMakeScale(1.025, 1.025)
//                    }), completion: nil)

                    
// This is with the growing/shrinking stripped out
//                    UIView.animateWithDuration(0.25 , delay: 2.0, options:[], animations: {
//                        currentViewVideoPlayer.layer.opacity = 1
//                        }, completion: nil)

// This is what I originally had
                    UIView.animateWithDuration(0.25 , delay: 1.0, options:[],
                                               animations: {
                                                currentViewVideoPlayer.alpha = 1
                                                currentViewVideoPlayer.transform = CGAffineTransformMakeScale(1.025, 1.025)
                        }, completion: { finish in
                            UIView.animateWithDuration(0.25){
                                currentViewVideoPlayer.transform = CGAffineTransformIdentity
                            }
                    })
                    
                    
                }
                
                videoIndex += 1
            }

            print("  DataViewController.swift - loadVideoThumbs() - videos loaded successfully.")
            
        } else  {
            // Fade in the "No videos found" label
            self.labelNoVideosFound.hidden = false
            self.labelNoVideosFound.alpha = 0
            
            UIView.animateWithDuration(0.5, delay: 1, options: [], animations: {
                self.labelNoVideosFound.alpha = 1
                
                }, completion: nil)
            
        }
    }

    
    
    // different behaviors for different orientations
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")

            let maskImage = UIImage(named: "halftone")  // this has the same square dimensions is imgArtist 325x325pt
            let maskLayer = CALayer()
            // you have to use the height (instead of the width) because at this state the screen hasn't changed orientation yet
            maskLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.height, 375)
            maskLayer.contents = maskImage?.CGImage
            self.imgArtist.layer.mask = maskLayer
            
        } else {
            print("Portrait")
            // remask the image
            let maskImage = UIImage(named: "halftone")  // this has the same square dimensions is imgArtist 325x325pt
            let maskLayer = CALayer()
            //maskLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, imgArtist.bounds.height)
            // you have to use the width (instead of the height) because at this state the screen hasn't changed orientation yet
            maskLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 400)
            maskLayer.contents = maskImage?.CGImage
            self.imgArtist.layer.mask = maskLayer

        }
    }
        
    
    @IBAction func gotoEventLink(sender: AnyObject) {
        if let url = NSURL(string: dataURLEvent) {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
    
    @IBAction func sayHi(sender: AnyObject) {
        print("hi")
    }
    
}