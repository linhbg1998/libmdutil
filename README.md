# libmdutil
 MobileDevice wrapper for swift*
 
 *this is a work in process... NOT READY YET*
 
 ### Syntax
 
 ```bash
# (un)registering a device #
libmdutil().register()
libmdutil().unregister()

# (un)pairing a device #
libmdutil().pair() # only 1 device connected
libmdutil().unpair() # only 1 device connected
libmdutil().pair(uuid: <uuid>)
libmdutil().unpair(uuid: <uuid>)

# copying a value #
libmdutil().value_for("VALUE") # only 1 device connected
libmdutil().value_for(uuid: <uuid>, <value>)

# print device information #
libmdutil().device_info() # only 1 device connected
libmdutil().device_info(uuid: <uuid>)

# entering recovery mode #
libmdutil().enter_recovery() # only 1 device connected
libmdutil().enter_recovery(uuid: <uuid>)

# exiting recovery mode #
libmdutil().exit_recovery() # only 1 device connected
libmdutil().exit_recovery(uuid: <uuid>)

# callbacks for connections #
libmdutil().cb_recovery_connect({ _ in <func> })
libmdutil().cb_recovery_disconnect({ _ in <func> })
libmdutil().cb_dfu_connect({ _ in <func> })
libmdutil().cb_dfu_disconnect({ _ in <func> })
libmdutil().cb_normal_connect({ _ in <func> })
libmdutil().cb_normal_disconnect({ _ in <func> })

# allowed pairing types #
libmdutil().allow_wireless_pairing(<bool>)
libmdutil().allow_local_pairing(<bool>)



 ```
