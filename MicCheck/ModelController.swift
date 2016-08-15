//
//  ModelController.swift
//  MicCheck
//
//  Created by Eric Nash on 10/27/15.
//  Copyright © 2015 Eric Nash Designs. All rights reserved.
//

import UIKit

/*
A controller object that manages a simple model -- a collection of events in a json file.

The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.

There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
*/

class ModelController: NSObject, UIPageViewControllerDataSource {
    
    // MARK: - Use Singleton to load up event objects from the JSON file and create the model
    let lineUp = LineUp.sharedInstance

    
    override init() {
        super.init()

        print(" ModelController.swift - init() - start and end")
        
    }
    
    func viewControllerAtIndex(index: Int, direction: String, storyboard: UIStoryboard) -> DataViewController? {
        
        print(" ModelController.swift - viewControllerAtIndex() - start")
        
        // Return the data view controller for the given index.
        if (self.lineUp.events.count == 0) || (index >= self.lineUp.events.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController

        dataViewController.dataIntEventIndex = index + 1
        dataViewController.dataIntEventCount = self.lineUp.events.count
        
        dataViewController.dataVenue = self.lineUp.events[index].venue!
        dataViewController.dataURLEvent = self.lineUp.events[index].urlEvent
        dataViewController.dataObject = self.lineUp.events[index].artist
        dataViewController.dataImgArtist = self.lineUp.events[index].imgArtist
        dataViewController.dataPrice = self.lineUp.events[index].price!
        
        dataViewController.swipeDirection = direction

        print(" ModelController.swift - viewControllerAtIndex() - current artists = \(dataViewController.dataObject)")


        // if there's nothing in the video queue then delay a couple seconds to see if there's data later


        print(" ModelController.swift - viewControllerAtIndex() - end")
        
        return dataViewController
    }
    
    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        
        return self.lineUp.events.indexOf { $0.artist == viewController.dataObject }!
        
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)

        print(" ModelController.swift - beforeViewController() start - index: \(index)")
        if (self.lineUp.events.count == 1) || (index == NSNotFound) {
            return nil
        }

        index -= 1
        let swipeDirection: String = "up"
        
        // if you're at the top and you swipe to go up again, restart at the end
        if index < 1 {
            return self.viewControllerAtIndex(self.lineUp.events.count - 1, direction: swipeDirection, storyboard: viewController.storyboard!)
        }

        return self.viewControllerAtIndex(index, direction: swipeDirection, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        print(" ModelController.swift - afterViewController() start - index: \(index)")
        
        if (self.lineUp.events.count == 1) || (index == NSNotFound) {
            return nil
        }
        
        index += 1
        let swipeDirection: String = "down"

        // if you're at the bottom and you swipe to go down again, restart at the beginning
        if index == self.lineUp.events.count {
            //return nil
            return self.viewControllerAtIndex(0, direction: swipeDirection, storyboard: viewController.storyboard!)
        }

        return self.viewControllerAtIndex(index, direction: swipeDirection, storyboard: viewController.storyboard!)
    }
    
    
    // I started this function from this site:
    /* http://stackoverflow.com/questions/30489920/ios-swift-uipageviewcontroller-turning-page-programatically?lq=1 */
    
    func setViewControllers(viewControllers: [AnyObject]!, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)!) {
        
        //        self.pageControl.currentPageIndex = pageViewController.viewControllers!.first!.view.tag
        //
        //        let current = self.pageViewController(<#T##pageViewController: UIPageViewController##UIPageViewController#>, viewControllerAfterViewController: <#T##UIViewController#>)
        //
        //        let pageContentViewController = self.pageViewController.viewControllers![0] as! ViewController
        //        let index = pageContentViewController.pageIndex
        //
        //        let viewController = self.viewControllerAtIndex(<#T##index: Int##Int#>, storyboard: <#T##UIStoryboard#>)
        //
        //
        //        let firstIndex = 0
        //        var index = self.indexOfViewController(viewController as! DataViewController)
        //        if index == NSNotFound {
        //            return nil
        //        }
        //
        //        return self.viewControllerAtIndex(firstIndex, storyboard: viewController.storyboard!)
        
    }
    //    func slideToFirstViewController(pageViewController: UIPageViewController, viewControllerAtIndex viewController: UIViewController) -> UIViewController?) {
    //        var index = self.indexOfViewController(viewController as! DataViewController)
    //        //var index = self.indexOfViewController(viewController as! DataViewController)
    //        if index < currentPageIndex {
    //            if let vc = viewControllerAtIndex(index) {
    //                self.pageViewController.setViewControllers([vc], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: { (complete) -> Void in
    //                    self.currentPageIndex = index
    //                    completion?()
    //                })
    //            }
    //        }
    //    }
    
    
}