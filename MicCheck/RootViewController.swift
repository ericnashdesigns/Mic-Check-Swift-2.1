//
//  RootViewController.swift
//  MicCheck
//
//  Created by Eric Nash on 10/27/15.
//  Copyright © 2015 Eric Nash Designs. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?

    // ERic: the index of the selected cell on the collectionViewController, which we'll use to fetch the proper viewController index
    var eventIndex: AnyObject? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("eventIndex")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.

        print("RootViewController.swift - viewDidLoad() - start")
        
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Vertical, options: nil)
        self.pageViewController!.delegate = self

        print("RootViewController.swift - viewControllerAtIndex() called for startingViewController")
        // ERic: swapped out the 0 for the monthIndex as an Int
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(eventIndex as! Int, direction: "down", storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        print("RootViewController.swift - setViewControllers() - called")
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect

        self.pageViewController!.didMoveToParentViewController(self)

        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers

        // ERic: hide the navigation bar but keep the back gesture
//        self.navigationController?.navigationBarHidden = true
//        if (((self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")))) != nil) {
//            self.navigationController?.interactivePopGestureRecognizer?.enabled = true
//            self.navigationController?.interactivePopGestureRecognizer!.delegate = self as? UIGestureRecognizerDelegate
//        }

        // RootViewController.swift - viewDidLoad() - this is a hack that puts the view under the navigationController
        self.pageViewController!.view.insertSubview(UIView(), atIndex: 0)
        
        print("RootViewController.swift - viewDidLoad() - end")
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .Portrait) || (orientation == .PortraitUpsideDown) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
            print("RootViewController.swift - spineLocationForInterfaceOrientation()")

            self.pageViewController!.doubleSided = false
            return .Min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfterViewController: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBeforeViewController: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })

        return .Mid
    }
    
    // hide the wifi connection, clock, and battery level

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

