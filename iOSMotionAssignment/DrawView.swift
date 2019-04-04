//
//  DrawView.swift
//  iOSTouch
//
//  Created by gliao on 2019-03-27.
//  Copyright © 2019 COMP1601. All rights reserved.
//

import UIKit

class DrawView: UIView {
    var currentLine: Line?
    var horizontalLine: Line?
    var projectile: Circle?
    
    var pixelsPerMeter: CGFloat?
    
    var theoreticalMax: CGPoint?
    var theoreticalLanding: CGPoint?

    var timer: Timer!
    var count: Int = 0
    var markerLocations = [CGPoint]()
    
    var lineThickness: CGFloat = 10
    @IBInspectable var launchSpeed: Int = 10 {
        didSet { setNeedsDisplay() }
    }
    
    // Start colours
    @IBInspectable var finishedLineColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }
    var horizontalLineColor = UIColor.gray
    var currentLineColor = UIColor.magenta
    @IBInspectable var circleFillColor = UIColor.blue {
        didSet { setNeedsDisplay() }
    }
    var greyGridColor = UIColor.lightGray
    var blueGridColor = UIColor.blue
    // End colours
    
    
    /** Draws a line */
    func strokeLine(line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.round
        
        // From cartesian to screen
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    /** Draws a circle */
    func strokeCircle(circle: Circle, rect: CGRect) {
        let path = UIBezierPath(ovalIn:
            CGRect(x: circle.center.x - circle.radius,
                   // From cartesian to screen coordinates
                   y: rect.height - (circle.center.y + circle.radius),
                   width: 2 * circle.radius,
                   height: 2 * circle.radius
            )
        )
        
        path.lineWidth = lineThickness
        
        // Fill circle with its colour attribute
        circle.colour.setFill()
        path.fill()
        
        path.stroke()
    }
    
    /** Runs a timer that calls updateTimer(timer:) every millisecond */
    func runTimer(rect: CGRect) {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.001,
                                         target: self,
                                         selector: #selector(DrawView.updateTimer),
                                         userInfo: rect,  // This is unused - used UIScreen.main.bounds instead
                                         repeats: true)
        }
    }
    
    @objc func updateTimer(timer: Timer) {  // Called every 1/1000th second
        count += 1
        // Advance the projectile
        if count % 10 == 0 && projectile != nil {
            let rect = UIScreen.main.bounds
            projectile!.advanceInArea(
                area: rect,
                // "Real" deltaT is 0.001 * 10, but timer is slow due to time
                // of running code, so deltaT is 0.001 * 100 seconds to adjust
                // and make motion look realistic
                deltaT: 0.001 * 100,
                pixelsPerMeter: pixelsPerMeter!
            )
            setNeedsDisplay()
        }
        // Drop a marker every once in a while
        if count % 75 == 0 && projectile != nil {
            markerLocations.append(projectile!.center)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        // Timer code
        if timer == nil {
            runTimer(rect: rect)
        }
        
        // Draw grid
        lineThickness = 1
        pixelsPerMeter = (rect.width > rect.height) ? rect.width / 1000 : rect.height / 1000
        // Draw vertical lines
        var count = 0
        for x in stride(from: 0, to: rect.width / pixelsPerMeter!, by: 20 * pixelsPerMeter!) {
            if count % 5 == 0 {
                blueGridColor.setStroke()
            }
            else {
                greyGridColor.setStroke()
            }
            let topEdge = CGPoint(x: CGFloat(x), y: 0)
            let bottomEdge = CGPoint(x: CGFloat(x), y: rect.height)
            strokeLine(line: Line(begin: topEdge, end: bottomEdge))
            
            count += 1
        }
        // Draw horizontal lines
        count = 0
        for y in stride(from: rect.height / pixelsPerMeter!, to: 0, by: -20 * pixelsPerMeter!) {
            if count % 5 == 0 {
                blueGridColor.setStroke()
            }
            else {
                greyGridColor.setStroke()
            }
            let leftEdge = CGPoint(x: 0, y: CGFloat(y) * pixelsPerMeter!)
            let rightEdge = CGPoint(x: rect.width, y: CGFloat(y) * pixelsPerMeter!)
            strokeLine(line: Line(begin: leftEdge, end: rightEdge))
            
            count += 1
        }
        
        // Draw axis labels every 200 x
        for x in stride(from: 200, to: rect.width / pixelsPerMeter! + 50, by: 200) {
            let xLabel: NSString = NSString(string: "\(Int(x))")
            let attributes: NSDictionary = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!
            ]
            let textSize: CGSize = xLabel.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
            let labelPosition: CGPoint = CGPoint(x: x * pixelsPerMeter! - textSize.width / 2, y: rect.height - 30)
            xLabel.draw(at: labelPosition, withAttributes: attributes as? [NSAttributedString.Key : Any])
        }
        
        // Draw markers
        lineThickness = 1
        for markerLocation in markerLocations {
            strokeCircle(circle:
                Circle(center: markerLocation,
                       radius: 2,
                       colour: UIColor.black),
             rect: rect)
        }
        
        // Draw theoretical maximum
        if theoreticalMax != nil {
            strokeCircle(
                circle: Circle(center: theoreticalMax!, radius: 6, colour: UIColor.red),
                rect: rect
            )
        }

        // Draw theoretical landing
        if theoreticalLanding != nil {
            strokeCircle(
                circle: Circle(center: theoreticalLanding!, radius: 6, colour: UIColor.green),
                rect: rect
            )
        }
        
        // Make center circle if not already done
        finishedLineColor.setStroke()
        lineThickness = 5
        if projectile == nil {
            let radius: CGFloat = 10
            projectile = Circle(
                center: CGPoint(  // In cartesian coordinates
                    x: 200 * pixelsPerMeter!,
                    y: 300 * pixelsPerMeter!),
                radius: radius)
        }
        strokeCircle(circle: projectile!, rect: rect)  // Draw it
        
        // Draw horizontal line
        if let line = horizontalLine {
            horizontalLineColor.setStroke()
            strokeLine(line: line)
        }
        
        // Draw currently touched line
        lineThickness = 10
        if let line = currentLine {
            currentLineColor.setStroke()
            strokeLine(line: line)
            
            /* Draw speed label */
            let speed = getSpeed(lineLength: line.getLength())
            let speedLabel: NSString = NSString(string: "\(String(format: "%.1f", speed)) m/sec")
            let attributes: NSDictionary = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!
            ]
            // Calculate location of text - should be centered on the location of currentLine
            let lineCenter = CGPoint(x: (line.begin.x + line.end.x) / 2,
                                     y: (line.begin.y + line.end.y) / 2)
            // Account for size of text
            let textSize: CGSize = speedLabel.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
            let labelPosition = CGPoint(x: lineCenter.x - textSize.width / 2,
                                        y: lineCenter.y - textSize.height / 2)
            // Draw label
            speedLabel.draw(at: labelPosition,
                            withAttributes: attributes as? [NSAttributedString.Key : Any])
            
            /* Draw angle label */
            let angle = line.getAngle()
            if angle != -1.0 {
                let angleLabel: NSString = NSString(string: "\(String(format: "%.1f", angle)) deg")
                // Calculate location of text - should be centered on the location of horizontalLine
                let horizontalLineCenter = CGPoint(
                    x: (horizontalLine!.begin.x + horizontalLine!.end.x) / 2,
                    y: (horizontalLine!.begin.y + horizontalLine!.end.y) / 2
                )
                // Account for size of text
                let textSize2: CGSize = angleLabel.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
                let labelPosition2 = CGPoint(
                    x: horizontalLineCenter.x - textSize2.width / 2,
                    y: horizontalLineCenter.y - textSize2.height / 2 + 20
                )
                // Draw label
                angleLabel.draw(at: labelPosition2,
                                withAttributes: attributes as? [NSAttributedString.Key : Any])
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: self)
        
        // Initialize lines
        currentLine = Line(begin: location, end: location)
        horizontalLine = Line(begin: location, end: location)
        
        // Reset markers if touched circle
        if projectile!.containsPoint(
            convertCoordinate(location, rect: UIScreen.main.bounds)) {
                markerLocations.removeAll()
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        // Update begin and end coordinates of both lines
        currentLine!.end = location
        horizontalLine!.begin.y = location.y
        horizontalLine!.end = location
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if projectile!.containsPoint(convertCoordinate(currentLine!.begin, rect: UIScreen.main.bounds)) {
            // Calculate velocities based on length of currentLine
            let speed = getSpeed(lineLength: currentLine!.getLength()) * Double(pixelsPerMeter!)
            let xVelocity = speed * Calculator.cos(degrees: currentLine!.getAngle())  // getAngle converts from screen to Cartesian
            let yVelocity = speed * Calculator.sin(degrees: currentLine!.getAngle())
            projectile!.setInitialVelocity(xVelocity: xVelocity, yVelocity: yVelocity)
            
            // Add marker for max height
            let timeOnMax = Calculator.getTimeOnMaxHeight(initialYVelocity: yVelocity)
            theoreticalMax = CGPoint(
                x: Calculator.getX(time: timeOnMax, initialSpeed: xVelocity, initialPosition: Double(projectile!.center.x)),
                y: Calculator.getY(time: timeOnMax, initialSpeed: yVelocity, initialPosition: Double(projectile!.center.y))
            )
            
            // Add marker for landing location
            let xOnLanding = Calculator.getXOnLanding(initialXVelocity: xVelocity, initialYVelocity: yVelocity, initialHeight: Double(projectile!.center.y)) + Double(projectile!.center.x)
            theoreticalLanding = CGPoint(x: xOnLanding, y: 3)  // y is 0 + half of radius
        }
        
        // "Delete" both lines
        currentLine = nil
        horizontalLine = nil
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        touchesEnded(touches, with: event)
    }
    
    func getSpeed(lineLength: Double) -> Double {
        return Double(launchSpeed) / 20.0 * lineLength
    }
    
    func convertCoordinate(_ cartesian: CGPoint, rect: CGRect) -> CGPoint {
        return CGPoint(x: cartesian.x, y: rect.height - cartesian.y)
    }
    
//    static func onRotate() {
//        if projectile != nil {
//            if (center.x + radius) > area.width && (velocity.x <= 0)
//                || (center.x - radius) < 0 && (velocity.x >= 0)
//                || (center.y + radius) > area.height && (velocity.y <= 0)
//                || (center.y - radius) < 0 && (velocity.y >= 0) {
//                print("Hit ground")
//            }
//
//        }
//    }
    
}
