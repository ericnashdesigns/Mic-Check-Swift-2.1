//
//  MKButton.swift
//  MicCheck
//
//  Created by Eric Nash on 7/30/16.
//  Copyright © 2016 Eric Nash Designs. All rights reserved.
//

import UIKit

class MKButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBInspectable internal var maskEnabled: Bool = true {
        didSet {
            mkLayer.enableMask(maskEnabled)
        }
    }
    @IBInspectable internal var rippleLocation: MKRippleLocation = .TapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    @IBInspectable internal var ripplePercent: Float = 0.9 {
        didSet {
            mkLayer.ripplePercent = ripplePercent
        }
    }
    @IBInspectable internal var backgroundLayerCornerRadius: CGFloat = 0.0 {
        didSet {
            mkLayer.setBackgroundLayerCornerRadius(backgroundLayerCornerRadius)
        }
    }
    // animations
    @IBInspectable internal var shadowAniEnabled: Bool = true
    @IBInspectable internal var backgroundAniEnabled: Bool = true {
        didSet {
            if !backgroundAniEnabled {
                mkLayer.enableOnlyCircleLayer()
            }
        }
    }
    @IBInspectable internal var rippleAniDuration: Float = 0.75
    @IBInspectable internal var backgroundAniDuration: Float = 1.0
    @IBInspectable internal var shadowAniDuration: Float = 0.65
    
    @IBInspectable internal var rippleAniTimingFunction: MKTimingFunction = .Linear
    @IBInspectable internal var backgroundAniTimingFunction: MKTimingFunction = .Linear
    @IBInspectable internal var shadowAniTimingFunction: MKTimingFunction = .EaseOut
    
    @IBInspectable internal var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            mkLayer.setMaskLayerCornerRadius(cornerRadius)
        }
    }
    // color
    @IBInspectable internal var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(rippleLayerColor)
        }
    }
    @IBInspectable internal var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }
    override internal var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }
    
    private lazy var mkLayer: MKLayer = MKLayer(superLayer: self.layer)
    
    // MARK - initilization
    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    // MARK - setup methods
    private func setupLayer() {
        adjustsImageWhenHighlighted = false
        cornerRadius = 2.5
        mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        mkLayer.setCircleLayerColor(rippleLayerColor)
    }
    
    // MARK - location tracking methods
    override internal func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        if rippleLocation == .TapLocation {
            mkLayer.didChangeTapLocation(touch.locationInView(self))
        }
        
        // rippleLayer animation
        mkLayer.animateScaleForCircleLayer(0.45, toScale: 1.0, timingFunction: rippleAniTimingFunction, duration: CFTimeInterval(self.rippleAniDuration))
        
        // backgroundLayer animation
        if backgroundAniEnabled {
            mkLayer.animateAlphaForBackgroundLayer(backgroundAniTimingFunction, duration: CFTimeInterval(self.backgroundAniDuration))
        }
        
        // shadow animation for self
        if shadowAniEnabled {
            let shadowRadius = layer.shadowRadius
            let shadowOpacity = layer.shadowOpacity
            let duration = CFTimeInterval(shadowAniDuration)
            mkLayer.animateSuperLayerShadow(10, toRadius: shadowRadius, fromOpacity: 0, toOpacity: shadowOpacity, timingFunction: shadowAniTimingFunction, duration: duration)
        }
        
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    
}
