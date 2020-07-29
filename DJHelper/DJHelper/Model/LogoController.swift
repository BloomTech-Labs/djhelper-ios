//
//  zzLogoController.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/27/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

@IBDesignable
class LogoView: UIView {
    var eqLevel: CGFloat = 0.5

    // MARK: - View Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        backgroundColor = .white
        self.contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        let backgroundMask = CAShapeLayer()
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.width * 0.25).cgPath
        layer.mask = backgroundMask

        let eqHeight = CGRect(origin: CGPoint(x: 0, y: rect.height), size: CGSize(width: rect.width, height: -(rect.height * eqLevel)))
        let eqLayer = CALayer()
        eqLayer.frame = eqHeight

        layer.addSublayer(eqLayer)
        eqLayer.backgroundColor = UIColor.white.cgColor
    }
}

//class OldLogoView: UIView {
//    // MARK: - Properties
//    var barWidth: CGFloat = 0
//    var maxHeight: CGFloat = 0
//    var minHeight: CGFloat = 0
//    var equalizer: [CGRect] = []
//
//    // MARK: - View Lifecycle
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//        self.contentMode = .redraw
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        backgroundColor = .clear
//        self.contentMode = .redraw
//    }
//
//    // MARK: - Draw Equalizer Elements
//    override func draw(_ rect: CGRect) {
//        let gridWidth: CGFloat = rect.size.width
//        let gridHeight: CGFloat = rect.size.height
//        let gridSquareX: CGFloat = gridWidth / 11
//        let gridSquareY: CGFloat = gridHeight / 14
//
//        self.barWidth = gridSquareX * 2
//        self.maxHeight = gridSquareY * 14
//        self.minHeight = gridSquareX * 2
//
//        // Four equalizer bars
//        var barOne = CGRect(x: 0, y: gridSquareY * 12, width: barWidth, height: minHeight)
//        addRectangle(addRect: barOne, withColor: .white)
//
//        var barTwo = CGRect(x: gridSquareX * 3, y: gridSquareY * 10, width: barWidth, height: gridSquareY * 4)
//        addRectangle(addRect: barTwo, withColor: .white)
//
//        var barThree = CGRect(x: gridSquareX * 6, y: gridSquareY * 6, width: barWidth, height: gridSquareY * 8)
//        addRectangle(addRect: barThree, withColor: .white)
//
//        var barFour = CGRect(x: gridSquareX * 9, y: gridSquareY * 8, width: barWidth, height: gridSquareY * 6)
//        addRectangle(addRect: barFour, withColor: .white)
//
//        self.equalizer = [barOne, barTwo, barThree, barFour]
//        animateLogo(with: self.equalizer)
//
//    }
//
//    func addRectangle(addRect rectangle: CGRect, withColor color: UIColor) {
//        if let context = UIGraphicsGetCurrentContext() {
//            context.addRect(rectangle)
//            context.setFillColor(color.cgColor)
//            context.fillPath()
//        }
//    }
//
//    func expand(from prevRect: CGRect, to rectangle: CGRect) {
//        var expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
//        expandAnimation.fromValue = prevRect
//        expandAnimation.toValue = rectangle
//        expandAnimation.fillMode = CAMediaTimingFillMode.forwards
//        expandAnimation.isRemovedOnCompletion = false
//    }
//
//    // MARK: - Animation
//    func animateLogo(with equalizer: [CGRect]) {
//
//        // randomly generate a height for the bars
//        // set bars to that height
//        // loop through for 2.5 seconds
//        let animationBlock = {
//            for _ in 1...10 {
//                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
//                    for position in 0..<equalizer.count {
//                        let prevRect: CGRect = self.equalizer[position]
//                        let randomHeight: CGFloat = CGFloat.random(in: 0.1...14.0)
//                        self.equalizer[position] = CGRect(x: CGFloat((self.barWidth / 2.0) * (CGFloat(position) * 3.0)), y: CGFloat(14.0 - randomHeight), width: self.barWidth, height: self.maxHeight / 14 * randomHeight)
////                        self.addRectangle(addRect: self.equalizer[position], withColor: .white)
////                        self.expand(from: prevRect, to: self.equalizer[position])
//                    }
//                }
//            }
//        }
//        UIView.animateKeyframes(withDuration: 2.5, delay: 0.5, options: [], animations: animationBlock, completion: nil)
//    }
//}
