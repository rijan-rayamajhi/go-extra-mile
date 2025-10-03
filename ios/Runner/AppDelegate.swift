import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps
import flutter_background_service_ios
import flutter_foreground_task

// Function to register plugins for flutter_foreground_task
func registerPlugins(registry: FlutterPluginRegistry) {
  GeneratedPluginRegistrant.register(with: registry)
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    GMSServices.provideAPIKey("AIzaSyALJWrVRZxhO9KfKlG4uHXOOQiSk_o2sh0")
    
    // Configure Flutter Background Service
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "dev.flutter.background.refresh"
    
    // Configure Flutter Foreground Task
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
    
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Handle notification when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([[.alert, .badge, .sound]])
  }
  
  // Handle notification tap
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}
