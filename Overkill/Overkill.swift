
import Foundation
import Cocoa
import ServiceManagement
import NotificationCenter

class LocalNotification: NSObject {
    
    func setNotification(title: String, message: String, image:NSImage? = nil)
    {
        let notification: NSUserNotification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
    }
}

class Overkill:NSViewController,NSTouchBarDelegate,NSUserNotificationCenterDelegate {
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var toggle:Bool = true
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
  
        self.createListeners()
        
        if let button = statusItem.button {
            button.image = NSImage.init(named: "overkill")
        }
        let menu = NSMenu()
        let toggle = NSMenuItem.init(title: "Toggle", action: #selector(toggleOK), keyEquivalent: "k")
        toggle.keyEquivalentModifierMask = NSEventModifierFlags(rawValue: UInt(Int(NSEventModifierFlags.option.rawValue)))
        toggle.target = self
        
        menu.addItem(toggle)
        menu.addItem(NSMenuItem.separator())
        
        let toggleRunOnStart = NSMenuItem.init(title: "Toggle Run On Start", action: #selector(registerOnLogin), keyEquivalent: "")
        toggleRunOnStart.target = self
        menu.addItem(toggleRunOnStart)
        
        let quit = NSMenuItem.init(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        
        statusItem.menu = menu

    }
    
    override func viewWillAppear() {
        let note = LocalNotification()
        note.setNotification(title: "Overkill", message: "Overkill Switched On")
    }
    
    func createListeners() {
        let workspaceNotificationCenter = NSWorkspace.shared().notificationCenter
        workspaceNotificationCenter.addObserver(self, selector: #selector(Overkill.appWillLaunch(note:)), name: .NSWorkspaceWillLaunchApplication, object: nil)
    }
    
    func isXcodeRunning() -> Bool {
        let apps:[NSRunningApplication] = NSWorkspace.shared().runningApplications
        for app in apps {
            if (app.localizedName == "Xcode") { return true }
            print("\(app.localizedName) \(app)")
        }
        return false
    }
    
    func registerOnLogin() {
        // launcher id
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/Contents/Library/LoginItems/HelperOverkillLauncher.app", isDirectory: true)
        let status : OSStatus = LSRegisterURL(helperURL as CFURL, true)
        if (status != noErr) {
            print("Failed to LSRegisterURL '%@': %jd", helperURL, status)
        }
        
        let launcherAppIdentifier:NSString = "com.angelica.ramos.OverkillLauncher"
        if (!SMLoginItemSetEnabled(launcherAppIdentifier, true)) {
            print("Failed To Register")
        }
        
        let note = LocalNotification()
        note.setNotification(title: "Register On Login: ", message: "Coming Soon! Not going to Lie it doesn't seem very easy to do ... =)")
        
        var startedAtLogin = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == launcherAppIdentifier as String {
                startedAtLogin = true
            }
        }
        
        if startedAtLogin {
            let noteName = NSNotification.Name.init("killme")
            DistributedNotificationCenter.default().post(name: noteName, object: Bundle.main.bundleIdentifier)
            print("Kill Launcher App")
        }
    }
    
    func appWillLaunch(note:Notification) {
        if (isXcodeRunning() == true) {
            if (toggle == true) {
                if let processName:String = note.userInfo?["NSApplicationName"] as? String {
                    print(processName)
                    if let processId = note.userInfo?["NSApplicationProcessIdentifier"] as? Int {
                        switch processName {
                        case "iTunes":
                            self.terminateProcessWith(processId,processName)
                        case "Photos":
                            self.terminateProcessWith(processId,processName)
                        default:break
                        }
                    }
                }
            }
        }
    }
    
    func terminateProcessWith(_ processId:Int,_ processName:String) {
        let process = NSRunningApplication.init(processIdentifier: pid_t(processId))
        process?.forceTerminate()
        let note = LocalNotification()
        note.setNotification(title: "Overkill", message: "Closed: \(processName)")
    }
    
    func toggleOK() {
        if self.toggle == true {
            self.toggle = false
            let note = LocalNotification()
            note.setNotification(title: "Overkill", message: "Overkill Switched Off")
        }
        else {
            self.toggle = true
            let note = LocalNotification()
            note.setNotification(title: "Overkill", message: "Overkill Switched On")
        }
    }
    
    func quitApp() {
        NSRunningApplication.current().terminate()
    }
}
