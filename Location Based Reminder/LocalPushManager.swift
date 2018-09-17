import Foundation
import UserNotifications

//A class that handle the local push notificaiton
class LocalPushManager: NSObject {
    static var shared = LocalPushManager()
    let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { (granted, error) in
            if error == nil {
                print("Permission granted")
            }
        }
    }
    
    //Set up local push with iOS
    func sendLocalPush(in time: TimeInterval) {
        //Create local push content
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "You are near your reminder location", arguments: nil)
        content.subtitle = NSString.localizedUserNotificationString(forKey: "This is a subtitle", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Duh, stop and check your surrounding or else you miss it", arguments: nil)
        content.badge = 1
        
        //Trigger push notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Timer", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error == nil {
                print("Schedule push succeed ")
            }
        }
    }
}
