import SwiftUI
import UserNotifications

struct ContentView: View {
    // This saves the last time you took the pill to the device's storage
    @AppStorage("lastTakenDate") private var lastTakenDate: Double = 0
    
    // State to show an alert if notifications are disabled
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "pills.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            if lastTakenDate > 0 {
                let date = Date(timeIntervalSince1970: lastTakenDate)
                Text("Last taken:\n\(date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            } else {
                Text("No pill recorded yet.")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                recordPillTaken()
            }) {
                Text("I Took My Pill")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 40)
            
            // --- DEBUG SECTION ---
            Button(action: {
                scheduleTestReminders()
            }) {
                Text("Debug: Test Notifications (5s)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            .padding(.top, 20)
            // ---------------------
        }
        .padding()
        .onAppear {
            requestNotificationPermissions()
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings so the app can remind you.")
        }
    }
    
    // MARK: - Logic
    
    private func recordPillTaken() {
        // 1. Save the current time
        lastTakenDate = Date().timeIntervalSince1970
        
        // 2. Schedule the reminders
        scheduleReminders()
        
#if os(iOS)
        // Optional: Trigger a tiny vibration feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
#endif
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if !success {
                DispatchQueue.main.async {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func scheduleReminders() {
        let center = UNUserNotificationCenter.current()
        
        // Clear all previous reminders
        center.removeAllPendingNotificationRequests()
        
        let customSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm.wav"))
        
        // Schedule new reminders starting at 10 hours, up to 60 hours
        // iOS allows a maximum of 64 pending notifications per app.
        for hourOffset in 10...60 {
            let content = UNMutableNotificationContent()
            
            if hourOffset < 12 {
                content.sound = .default
                content.title = "Pill Reminder Approaching"
                content.body = "You need to take your blood thinner in \(12 - hourOffset) hour(s)."
            } else if hourOffset == 12 {
                content.sound = customSound
                content.title = "Time to Take Your Pill!"
                content.body = "It has been exactly 12 hours. Please take your blood thinner now."
            } else {
                content.sound = customSound
                content.title = "OVERDUE: Pill Reminder"
                content.body = "You are \(hourOffset - 12) hour(s) late taking your blood thinner! Please take it immediately."
            }
            
            // Calculate the time interval in seconds
            let timeInterval = TimeInterval(hourOffset * 3600)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            
            // Create the request
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // Add to the notification center
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func scheduleTestReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let customSound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alarm.wav"))
        
        // Schedule test reminders starting in 5 seconds, then 10s, 15s
        for (index, timeOffset) in [5, 10, 15].enumerated() {
            let content = UNMutableNotificationContent()
            
            if index == 0 {
                content.sound = .default
                content.title = "Pill Reminder Approaching (TEST)"
                content.body = "This is a test. Your pill is due soon!"
            } else if index == 1 {
                content.sound = customSound
                content.title = "Time to Take Your Pill! (TEST)"
                content.body = "Please take your blood thinner now."
            } else {
                content.sound = customSound
                content.title = "OVERDUE: Pill Reminder (TEST)"
                content.body = "You are late taking your blood thinner!"
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeOffset), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling test notification: \(error)")
                }
            }
        }
    }
}
