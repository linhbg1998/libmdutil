//
//  ViewController.swift
//  libmdutil
//
//  Created by staturnz on 3/11/23.
//

import Cocoa

class ViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var model: NSTextField!
    @IBOutlet weak var ios: NSTextField!
    @IBOutlet weak var arch: NSTextField!
    @IBOutlet weak var mode: NSTextField!
    
    override func viewDidAppear() {
        libmdutil().register()
    }
    
    @IBAction func exit(_ sender: Any) {
        libmdutil().exit_recovery()
    }
    
    @IBAction func real(_ sender: Any) {
        let iboot = libmdutil().value_for("FirmwareVersion")
        let type = libmdutil().value_for("ProductType")
        let ios2 = libmdutil().value_for("ProductVersion")
        let arch2 = libmdutil().value_for("CPUArchitecture")
        
        model.stringValue = "Model: \(type)"
        ios.stringValue = "iOS: \(ios2)"
        arch.stringValue = "Arch: \(arch2)"
        mode.stringValue = "iBoot: \(iboot)"

    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func bruh(_ sender: Any) {
        libmdutil().enter_recovery()
    }
    

}

