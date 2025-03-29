import SwiftUI
import Foundation
import CoreLocation

// This is a workaround for Swift Playgrounds since you can't edit Info.plist directly
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Request location permissions early
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        return true
    }
}

@main
struct GolfTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
