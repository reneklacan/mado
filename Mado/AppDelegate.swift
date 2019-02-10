//
//  AppDelegate.swift
//  Mado
//
//  Created by Rene Klacan on 10/02/2019.
//  Copyright © 2019 Rene Klacan. All rights reserved.
//

import Cocoa
import HotKey
import Foundation
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!

    private var mainKeys = [Key.one, Key.two, Key.three, Key.four, Key.five]
    private var captureHotkeys: [HotKey]?
    private var invokeHotkeys: [HotKey]?
    private var capturedWindows: [Key: Int32] = [:]

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "TrayIcon")
        icon?.isTemplate = true

        statusItem.button!.image = icon
        statusItem.menu = statusMenu

        registerHotkeys(self)
    }

    func registerHotkeys(_ sender: Any?) {
        captureHotkeys = mainKeys.map({ key in
            let hotkey = HotKey(key: key, modifiers: [.command, .option])
            hotkey.keyDownHandler = { [weak self] in
                let activeWindowPid = Int32(NSWorkspace.shared.frontmostApplication!.processIdentifier)

                self!.capturedWindows[key] = activeWindowPid

                print("capture pid \(activeWindowPid) on \(key) at \(Date())")
            }
            return hotkey
        })

        invokeHotkeys = mainKeys.map({ key in
            let hotkey = HotKey(key: key, modifiers: [.option])
            hotkey.keyDownHandler = { [weak self] in
                if let capturedWindowPid = self!.capturedWindows[key] {
                    self!.switchToApp(withPid: capturedWindowPid)
                } else {
                    NSSound.beep()
                }
            }
            return hotkey
        })
    }

    func switchToApp(withPid pid: Int32) {
        let app = NSRunningApplication(processIdentifier: pid)
        app?.activate(options: .activateIgnoringOtherApps)
    }
}
