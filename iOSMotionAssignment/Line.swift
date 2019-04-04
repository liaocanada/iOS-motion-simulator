import Foundation
import CoreGraphics

struct Line {
    // In cartesian
    var begin = CGPoint.zero
    var end = CGPoint.zero
    
    init(begin: CGPoint, end: CGPoint) {
        self.begin = begin
        self.end = end
    }
    
    /** Returns the length of this line */
    func getLength() -> Double {
        let xDist = Double(begin.x - end.x)
        let yDist = Double(begin.y - end.y)
        return sqrt(xDist * xDist + yDist * yDist)
    }
    
    /** Returns the angle at which the projectile should be launched. */
    func getAngle() -> Double {
        
        // Reverse direction of dragging by multiplying by -1
        let xDirection = -1 * (end.x - begin.x)
        let yDirection = -1 * -1 * (end.y - begin.y)  // Convert to Cartesian by multiplying by -1 again
        
        let relatedAcuteAngle = abs(Calculator.tanInverse(opposite: Double(yDirection), adjacent: Double(xDirection)))
        if xDirection > 0 && yDirection >= 0 {  // Towards top right corner (quadrant 1 in Cartesian plane)
            return relatedAcuteAngle
        }
        if xDirection <= 0 && yDirection > 0 {  // Towards top left corner (Q2)
            return 180 - relatedAcuteAngle
        }
        if xDirection < 0 && yDirection <= 0 {  // Towards bottom left corner (Q3)
            return 180 + relatedAcuteAngle
        }
        if xDirection >= 0 && yDirection < 0 {  // Towards bottom right corner (Q4)
            return 360 - relatedAcuteAngle
        }
        return -1
    }
}
