
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let mainAppId = "com.angelica.ramos.Overkill"
        let running = NSWorkspace.shared().runningApplications
        var alreadyRunning = false
        for app in running {
            if app.bundleIdentifier == mainAppId {
                alreadyRunning = true
                break
            }
        }
        
        if !alreadyRunning {
            let noteName = Notification.Name("killme")
            DistributedNotificationCenter.default.addObserver(self, selector: #selector(terminate), name: noteName, object: mainAppId)
            
            let path = Bundle.main.bundlePath as NSString
            var comps = path.pathComponents
            comps.removeLast()
            comps.removeLast()
            comps.removeLast()
            comps.append("MacOS")
            comps.append("Overkill")
            
            let newPath = NSString.path(withComponents: comps)
            print(newPath)
            let isRunningApp = NSWorkspace.shared().launchApplication(newPath)
            
            print("Is Running App? \(isRunningApp)")
            
        } else {
            self.terminate()
        }
        
    }
    
    func terminate() {
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

