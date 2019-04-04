import Foundation
import CoreGraphics

let ACCELERATION_FROM_GRAVITY: Double = -9.81

class Calculator {
    /* Trig functions in degrees */
    static func sin(degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    }
    static func cos(degrees: Double) -> Double {
        return __cospi(degrees/180.0)
    }
    static func tan(degrees: Double) -> Double {
        return __tanpi(degrees/180.0)
    }
    static func tanInverse(opposite: Double, adjacent: Double) -> Double {
        return atan(opposite / adjacent) * 180 / Double.pi
    }
    /* End trig functions in degrees */
    
    
    /** Gets x at a given time and initial horizontal velocity.
     * Assumes horizontal acceleration is 0.
     */
    static func getX(time: Double, initialSpeed: Double, initialPosition: Double) -> Double {
        return time * initialSpeed + initialPosition
    }
    
    /** Gets y at a given time, initial vertical velocity, and initial height. */
    static func getY(time: Double, initialSpeed: Double, initialPosition: Double) -> Double {
        // Broken up into smaller chunks to get around following error:
        // "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
        let term1 = 0.5 * ACCELERATION_FROM_GRAVITY * time * time
        let term2 = initialSpeed * time
        let term3 = initialPosition
        return term1 + term2 + term3
    }
    
    /** Returns the time at which the projectile's vertical position is 0 */
    static func getTimeOnLanding(initialYVelocity: Double, initialHeight: Double) -> Double {
        // Broken up into smaller chunks to get around following error:
        // "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
        let temp = sqrt(initialYVelocity * initialYVelocity - 2 * ACCELERATION_FROM_GRAVITY * initialHeight)
        return (-initialYVelocity - temp) / ACCELERATION_FROM_GRAVITY
    }
    
    /** Returns the x at which the projectile's y is 0 */
    static func getXOnLanding(initialXVelocity: Double, initialYVelocity: Double, initialHeight: Double) -> Double {
        let time: Double = getTimeOnLanding(initialYVelocity: initialYVelocity, initialHeight: initialHeight)
        return initialXVelocity * time
    }
    
    static func getTimeOnMaxHeight(initialYVelocity: Double) -> Double {
        if initialYVelocity <= 0 { return 0.0 }  // If shooting down, max height is initial height
        return initialYVelocity / -ACCELERATION_FROM_GRAVITY
    }
}
