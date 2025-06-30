//
//  receipt_shareApp.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Firebase for local emulators in local network environment
//        Auth.auth().useEmulator(withHost: "192.168.1.9", port: 9099)
//        Functions.functions().useEmulator(withHost: "192.168.1.9", port: 5001)
//        Storage.storage().useEmulator(withHost: "192.168.1.9", port: 9199)
//        let settings = Firestore.firestore().settings
//        settings.host = "192.168.1.9:8080"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
        // Configure Firebase for local emulators
//        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
//        Functions.functions().useEmulator(withHost: "localhost", port: 5001)
//        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8080"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
        return true
    }
    
    // Handle Universal Links
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        print("Received user activity: \(userActivity.activityType)")
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }
        guard let params = components.queryItems else {
            return false
        }
        if let groupId = params.first(where: { $0.name == "groupId" })?.value {
            print("Received groupId: \(groupId)")
            return true
        } else {
            print("No groupId found in URL")
            return false
        }
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct receipt_shareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var authViewModel = AuthViewModel(authRepository: FirebaseAuthRepository())
    @State var handleInvitationViewModel = HandleInvitationViewModel(invitationRepository: FirebaseInviteRepository())
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.currentUser != nil {
                ContentView(user: authViewModel.currentUser!)
                    .environment(authViewModel)
                    .onOpenURL(perform: { url in
                        print("App opened with URL: \(url)")
                        Task {
                            await handleInvitationViewModel.verifyInvitationLink(url)
                        }
                    })
                    .alert("招待リンクエラー", isPresented: .constant(handleInvitationViewModel.errorMessage != nil), actions: {
                        Button("OK") {
                            handleInvitationViewModel.errorMessage = nil
                        }
                    }, message: {
                        Text(handleInvitationViewModel.errorMessage ?? "")
                    })
            } else {
                SignInView()
                    .environment(authViewModel)
            }
        }
    }
}
