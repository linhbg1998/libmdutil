//
//  main.swift
//  md-util
//
//  Created by staturnz on 3/10/23.
//

import Foundation

print("[md-util] v1.0.0b1")

class libmdutil {
    
    func register() -> Void {
        md_register()
        print("[md-util] Device registered.");
    }
    
    func enter_recovery() -> Void {
        register()
        print("[md-util] Entering recovery mode when devices connects.");
        md_enter_rec()
    }
    
    func value_for(_ key: String) -> String {
        md_register()
        let info: NSMutableDictionary = device_info
        
        if let val: String = info[key] as? String {
            print("[md-util] '\(key)' = \(val)")
            return val
        } else {
            print("[md-util] Error: '\(key)' is not a valid key or value is nil")
            return "invalid"
        }
    }
    
    func device_scan() {
        var swift_is_dfu = false;
        var swift_is_rec = false;
        var swift_is_normal = false;
        
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            while (true) {
                if (is_dfu != swift_is_dfu) {
                    if (is_dfu) {
                        print("[md-util] Device connected in DFU Mode.") // do something else when connected if you wish
                    } else {
                        print("[md-util] Device disconnected from DFU Mode.") // do something else when disconnected if you wish
                    }
                }
                    
                if (is_rec != swift_is_rec) {
                    if (is_rec) {
                        print("[md-util] Device connected in Recovery Mode.") // do something else when connected if you wish
                    } else {
                        print("[md-util] Device disconnected from Recovery Mode.") // do something else when disconnected if you wish
                    }
                }

                if (is_normal != swift_is_normal) {
                    if (is_normal) {
                        print("[md-util] Device connected in Normal Mode.") // do something else when connected if you wish
                    } else {
                        print("[md-util] Device disconnected from Normal Mode.") // do something else when disconnected if you wish
                    }
                }
                swift_is_dfu = is_dfu
                swift_is_rec = is_rec
                swift_is_normal = is_normal
                usleep(100000)
            }
        }
    }
}

libmdutil().register()
libmdutil().device_scan()





