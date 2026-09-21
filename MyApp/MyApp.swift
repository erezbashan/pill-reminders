import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // This tells iOS to show the banner and play the sound even when the app is actively on screen
        completionHandler([.banner, .sound, .list])
    }
}

@main
struct MyApp: App {
    // Keep a strong reference to our custom delegate
    let notificationDelegate = NotificationDelegate()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
