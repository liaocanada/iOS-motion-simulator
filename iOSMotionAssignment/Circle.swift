import Foundation
import CoreGraphics
import UIKit

struct Circle {
    var center = CGPoint.zero
    var radius: CGFloat = 40.0
    var velocity: CGPoint = CGPoint.zero  // Treat as a vector
    var colour = UIColor.blue
    
    init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }
    init(center: CGPoint, radius: CGFloat, colour: UIColor) {
        self.center = center
        self.radius = radius
        self.colour = colour
    }
    
    /** Returns the screen distance to a point in screen units */
    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        let xDist = center.x - point.x
        let yDist = center.y - point.y
        return sqrt(xDist * xDist + yDist * yDist)
    }
    
    func containsPoint(_ point: CGPoint) -> Bool {
        return distanceToPoint(point) <= radius
    }
    
    /** Sets the initial velocity of the circle. Parameters should be in Cartesian units. */
    mutating func setInitialVelocity(xVelocity: Double, yVelocity: Double) {
        velocity = CGPoint(x: xVelocity, y: yVelocity)  // In Cartesian coordinates
    }
    
    /** Advances the circle within the specified area, during the specified time */
    mutating func advanceInArea(area: CGRect, deltaT: CGFloat, pixelsPerMeter: CGFloat) {
        
        // Bounce (flip velocity) if at the border
        if (center.x + radius) >= area.width && (velocity.x > 0) {
            velocity.x = -velocity.x
        }
        else if (center.x - radius) <= 0 && (velocity.x < 0) {
            velocity.x = -velocity.x
        }
        if (center.y + radius) >= area.height && (velocity.y > 0) {
            velocity.y = -velocity.y
        }
        // Stop circle if it hits the bottom
        else if (center.y - radius) <= 0 && (velocity.y < 0) {
            print("Hit ground")
            velocity = CGPoint.zero
        }
        
        // Move circle if there is velocity
        if velocity.x != 0 || velocity.y != 0 {
            center.x += velocity.x * deltaT * pixelsPerMeter
            center.y += velocity.y * deltaT * pixelsPerMeter
            // Update velocity based on Euler's approximation (x velocity doesn't change)
            velocity.y += CGFloat(ACCELERATION_FROM_GRAVITY) * deltaT
        }
        
    }
}
