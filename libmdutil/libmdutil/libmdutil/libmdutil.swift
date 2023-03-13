//
//  libmdutil.swift
//  libmdutil
//
//  Created by staturnz on 3/11/23.
//

import Foundation
import Darwin
import MachO
import libkern
import System


@objc public class libmdutil_objc: NSObject {
    
    @objc public func set_info(_ info:NSMutableDictionary) {
        print("[libmdutil] Received new info update")
        libmdutil().device_sysinfo = info
    }

    @objc public func on_recovery_connected(_ device:am_recovery_device) {
        print("[libmdutil] Device connected in Recovery Mode.")
        var _: () = libmdutil().cb_recovery_connect
    }
    
    @objc public func on_recovery_disconnected(_ device:am_recovery_device) {
        print("[libmdutil] Device disconnected from Recovery Mode.")
        var _: () = libmdutil().cb_recovery_disconnect
    }
    
    @objc public func on_dfu_connected(_ device:am_recovery_device) {
        print("[libmdutil] Device connected in DFU Mode.")
        var _: () = libmdutil().cb_dfu_connect
    }
    
    @objc public func on_dfu_disconnected(_ device:am_recovery_device) {
        print("[libmdutil] Device disconnected from DFU Mode.")
        var _: () = libmdutil().cb_dfu_disconnect
    }
    
    @objc public func on_normal_connected() {
        print("[libmdutil] Device connected in Normal Mode.")
        var _: () = libmdutil().cb_normal_connect
    }
    
    @objc public func on_normal_disconnected() {
        print("[libmdutil] Device disconnected from Normal Mode.")
        var _: () = libmdutil().cb_normal_disconnect
    }
}


class libmdutil {
    
    let MDERR_OK = 0
    let MDERR_DEVREQ_FAILED = 21
    let MDERR_CMD_FAILED = 2006
    let MDERR_SYSCALL = (0 | 0x01)
    let MDERR_OUT_OF_MEMORY = (0 | 0x03)
    let MDERR_QUERY_FAILED = (0 | 0x04)
    let MDERR_INVALID_ARGUMENT = (0 | 0x0b)
    let MDERR_DICT_NOT_LOADED = (0 | 0x25)
   
    public var device_sysinfo: NSMutableDictionary = [:]
    
    var cb_recovery_connect: ()
    var cb_recovery_disconnect: ()
    var cb_dfu_connect: ()
    var cb_dfu_disconnect: ()
    var cb_normal_connect: ()
    var cb_normal_disconnect: ()
    
    func register() -> Bool {
        let ret: Bool = md_register()
        if (ret) {print("[libmdutil] Register Successful.")}
        else {print("[libmdutil] Register Failed.")}
        return ret
    }

    func enter_recovery() -> Bool {
        device_delayed_unregister_aborted = true;
        let ret = AMDeviceValidatePairing(current_device);
        
        if (ret == MDERR_OK) {
            device_connect(current_device)
            AMDeviceEnterRecovery(current_device)
            device_unregister(0);
            return true
        } else if (ret == MDERR_INVALID_ARGUMENT) {
            print("[libmdutil] Error: Device is not paired or trusted.")
            return false
        } else {
            print("[libmdutil] Unknown error entering recovery: \(ret)")
            return false
        }
    }
    
    func exit_recovery() -> Void {
        print("[libmdutil] Exiting recovery mode when devices connects.")
        AMRecoveryModeDeviceSetAutoBoot(current_rec_device, 1)
        AMRecoveryModeDeviceReboot(current_rec_device, "" as CFString)
    }
    
    func cmd(_ command: String) -> Bool {
        let cf_command: CFString = command as CFString
        let ret = md_send_cmd(cf_command)
        
        if (ret == MDERR_OK) {
            print("[libmdutil] Command: \(command) ran succecfully.")
            return true
        } else if (ret == MDERR_DEVREQ_FAILED) {
            print("[libmdutil] Command: '\(command)' failed (MDERR_DEVREQ_FAILED).")
            return false
        } else if(ret == MDERR_CMD_FAILED) {
            print("[libmdutil] Command: '\(command)' failed (MDERR_CMD_FAILED).")
            return false
        } else {
            print("[libmdutil] Command: '\(command)' failed with an unknown error: \(ret).")
            return false
        }

    }
    
    func value_for(_ key: String) -> String {
        let info: NSMutableDictionary = device_info
        
        if let val: String = info[key] as? String {
            print("[libmdutil] '\(key)' = \(val)")
            return val
        } else {
            print("[libmdutil] Error: '\(key)' is not a valid key or value is nil")
            return "invalid"
        }
    }
    
}
