//
//  ViewController.swift
//  MarkovLettersApp
//
//  Created by Simon Rodriguez on 19/11/2015.
//  Copyright © 2015 Simon Rodriguez. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadFile:"), name: "LOAD_FILE", object: self)
        // Do any additional setup after loading the view.
    }
    
    func loadFile(path : String){
        do {
            let fullString = try String(contentsOfFile: path)
            var comps = fullString.componentsSeparatedByString("\n")
            let size = comps.removeFirst().stringByReplacingOccurrencesOfString("-", withString: " x ")
            NSApp.windows.first?.title = "Grid of size " + size
            textView.string = comps.joinWithSeparator("\n")
        } catch _ {
            textView.string = "ERROR loading the file at path:\n" + path
        }
    }
    
    

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

