// --- START OF FILE GolfTracker.swiftpm/Sources/Controllers/WindCalculator.swift ---

import Foundation

struct WindCalculator {

    // Define factors as constants for clarity
    private static let headwindDistanceFactor: Double = 2.5 // meters added/subtracted per m/s of head/tailwind
    private static let crosswindDistanceFactor: Double = 0.8 // meters subtracted per m/s of crosswind

    /**
     Calculates the estimated impact of wind on a golf shot distance.

     - Parameters:
       - distance: The intended shot distance in meters (used for context, not direct calculation).
       - windSpeed: Wind speed in meters per second (m/s).
       - windDirection: Wind direction in degrees (0 = North, 90 = East, etc. - blowing FROM this direction).
                        Assumes the shot is aimed straight North (0 degrees) for calculation simplicity.
                        Adjustments for shot direction are not included here.
     - Returns: The estimated distance adjustment in meters (negative for shorter, positive for longer).
     */
    static func calculateImpact(distance: Int, windSpeed: Double, windDirection: Double) -> Int {
        guard windSpeed > 0 else {
            return 0 // No wind, no impact
        }

        // Convert wind direction (degrees) to radians for trigonometric functions
        // Note: Using windDirection directly assumes the player aims North (0 deg).
        // A more complex calculation would involve player aim direction.
        let windDirectionRadians = (windDirection * .pi) / 180.0

        // Calculate headwind/tailwind component
        // cos(0) = 1 (North wind = pure headwind), cos(180) = -1 (South wind = pure tailwind)
        let headwindComponent = cos(windDirectionRadians) * windSpeed

        // Calculate crosswind component
        // sin(90) = 1 (East wind = pure right-to-left), sin(270) = -1 (West wind = pure left-to-right)
        let crosswindComponent = sin(windDirectionRadians) * windSpeed

        // Calculate impact based on components and factors
        // Headwind impact is negative (reduces distance), Tailwind is positive (increases distance)
        let headwindImpact = -headwindComponent * headwindDistanceFactor
        // Crosswind impact is always negative (reduces distance due to less efficient flight/spin)
        let crosswindImpact = -abs(crosswindComponent) * crosswindDistanceFactor // Use abs() as crosswind hurts from both sides

        // Total impact is the sum of headwind/tailwind and crosswind effects
        let totalImpact = headwindImpact + crosswindImpact

        // Return the rounded integer value of the impact
        return Int(totalImpact.rounded())
    }
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Controllers/WindCalculator.swift ---
