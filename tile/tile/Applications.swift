//
//  Applications.swift
//  tile
//
//  Created by Phillip Vance on 12/27/21.
//


import Foundation
import Cocoa

class Applications {
    var applications: [Application]?

    init() {}

    func start() {
        applications = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .filter { $0.bundleIdentifier != Bundle.main.bundleIdentifier }
            .map({ (app) -> Application in
                let application = Application(app.processIdentifier)
                application.start()
                return application
            })

        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidLaunch(notification:)), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appDidTerminate(notification:)), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
    }

    @objc private func appDidLaunch(notification: Notification) {
        let app = self.getRunningApplication(notification)
        guard app.bundleIdentifier! != Bundle.main.bundleIdentifier! else { return }
        let application = Application(app.processIdentifier)
        application.start()
        applications?.append(application)
    }

    @objc private func appDidTerminate(notification: Notification) {
        let app = self.getRunningApplication(notification)
        applications = applications?.filter { !$0.isPid(app.processIdentifier) }
    }

    private func getRunningApplication(_ notification: Notification) -> NSRunningApplication {
        return (notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)!
    }
}
