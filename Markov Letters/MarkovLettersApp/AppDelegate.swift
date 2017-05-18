//
//  AppDelegate.swift
//  MarkovLettersApp
//
//  Created by Simon Rodriguez on 19/11/2015.
//  Copyright © 2015 Simon Rodriguez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        //print(NSApplication.sharedApplication().windows.first?.contentViewController)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        (sender.windows.first?.contentViewController as! ViewController).loadFile(filename)
        return true
    }

}

