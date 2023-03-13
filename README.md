# libmdutil
 MobileDevice wrapper for swift*
 
 *this is a work in process... NOT READY YET*
 
 you need to add MobileDevice.framework for this to build,
 also can only target x86_64 not arm64 (M1/M2), works fine with rosetta though
 
 ### Syntax
 
 ```swift
// (un)registering a devic
libmdutil().register()
libmdutil().unregister()

// copying a value
libmdutil().value_for("value")

// print device information
libmdutil().device_info()

// entering recovery mode
libmdutil().enter_recovery()

// exiting recovery mode
libmdutil().exit_recovery()

// callbacks for connections
libmdutil().cb_recovery_connect = your_func()
libmdutil().cb_recovery_disconnect = your_func()
libmdutil().cb_dfu_connect = your_func()
libmdutil().cb_dfu_disconnect = your_func()
libmdutil().cb_normal_connect = your_func()
libmdutil().cb_normal_disconnect = your_func()

// run a command
libmdutil().cmd("command")

 ```
