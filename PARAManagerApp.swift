import SwiftUI
import AppKit

@main
struct PARAManagerApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ProjectsView()
                .onAppear {
                    // Ensure window comes to foreground when view appears
                    DispatchQueue.main.async {
                        NSApplication.shared.activate(ignoringOtherApps: true)
                    }
                }
        }
        .windowStyle(.automatic)
        .windowResizability(.automatic)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app activates and comes to foreground on launch
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Set up any additional window management here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApplication.shared.windows.first {
                window.title = "PARAManager"
                
                // Set minimum window size to prevent narrow window
                window.minSize = NSSize(width: 600, height: 400)
                
                // // Set initial frame to ensure proper width
                // let initialFrame = NSRect(x: 0, y: 0, width: 800, height: 600)
                // window.setFrame(initialFrame, display: true)
                
                // Center the window on screen
                window.center()
                
                // Bring window to front
                window.makeKeyAndOrderFront(nil)
                window.makeMain()
            }
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Ensure window comes to foreground when app becomes active
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
