//
//  GradientCollectionView.swift
//  MicCheck
//
//  Created by Eric Nash on 6/28/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

class GradientCollectionView: UICollectionView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var lastElementIndex: Int = 0
    var colors: Array<UIColor> = [] {
        didSet {
            lastElementIndex = colors.count - 1
        }
    }
    
    var index: Int = 0
    
    // ERic added: the CollectionViewController will call animateToNextGradient in order to set this to true
    // once the data has been fetched, the CollectionViewController will set it back to false
    var continueAnimating = false
    
// Core Animation provides CADisplayLink as a class that links a callback to the native screen updates. The callback passed will be called just before the screen gets redrawn so it provides with an ideal place to update our model, which in our case is factor.
    lazy var displayLink : CADisplayLink = {
        let displayLink : CADisplayLink = CADisplayLink(target: self, selector: #selector(GradientCollectionView.screenUpdated(_:)))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        return displayLink
    }()
    
    
    func animateToNextGradient() {
        
        index = (index + 1) % colors.count
        
        // the factor variable adds a kind of weighting to each color, the more we move towards 1.0 the less x1 matters to the sum and the more x2 takes precedence
        factor = 0.0
        

        // Core Animation provides us with a class that links a callback to the native screen updates by the name of CADisplayLink. The callback passed will be called just before the screen gets redrawn so it provides with an ideal place to update our model, which in our case is the singular value, factor
        self.displayLink.paused = false
        
        // ERic added
        self.continueAnimating = true
        
        
    }
    
    var factor: CGFloat = 1.0
    
    func screenUpdated(displayLink : CADisplayLink) {
        
        self.factor += CGFloat(displayLink.duration)
        
        if(self.factor > 1.0) {
            
            if (self.continueAnimating) {
                self.animateToNextGradient()
            } else {  // don't continue animating
                self.displayLink.paused = true
            }

        }
        
        self.setNeedsDisplay()
    }
    
    
    
    override func drawRect(rect: CGRect) {
        
        if colors.count < 2 {
            return;
        }
        
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context);
        
        let c1 = colors[index == 0 ? lastElementIndex : index - 1]    // => previous color from index
        let c2 = colors[index]                                        // => current color
        let c3 = colors[index == lastElementIndex ? 0 : index + 1]    // => next color
        
        let c1Comp = CGColorGetComponents(c1.CGColor)
        let c2Comp = CGColorGetComponents(c2.CGColor)
        let c3Comp = CGColorGetComponents(c3.CGColor)
        
        
        var colorComponents = [
            
            c1Comp[0] * (1 - factor) + c2Comp[0] * factor,
            c1Comp[1] * (1 - factor) + c2Comp[1] * factor,
            c1Comp[2] * (1 - factor) + c2Comp[2] * factor,
            c1Comp[3] * (1 - factor) + c2Comp[3] * factor,
            
            c2Comp[0] * (1 - factor) + c3Comp[0] * factor,
            c2Comp[1] * (1 - factor) + c3Comp[1] * factor,
            c2Comp[2] * (1 - factor) + c3Comp[2] * factor,
            c2Comp[3] * (1 - factor) + c3Comp[3] * factor
            
        ]
        
        
        let gradient = CGGradientCreateWithColorComponents(
            CGColorSpaceCreateDeviceRGB(),
            &colorComponents,
            [0.0, 1.0],
            2
        )
        
        
        CGContextDrawLinearGradient(
            context,
            gradient,
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: 0, y: rect.size.height),
            CGGradientDrawingOptions(rawValue: 0)
        )
        
        CGContextRestoreGState(context);
        
    }
    
    
}
