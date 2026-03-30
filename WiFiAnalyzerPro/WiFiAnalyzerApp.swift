import SwiftUI

@main
struct WiFiAnalyzerApp: App {
    @StateObject private var auth = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    ContentView()
                        .environmentObject(auth)
                } else {
                    LoginView()
                        .environmentObject(auth)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: auth.isAuthenticated)
        }
    }
}
