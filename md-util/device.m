//
//  device.m
//  md-util
//
//  Created by staturnz on 3/10/23.
//

#import <Foundation/Foundation.h>
#import <stdio.h>
#import <unistd.h>
#import <stdlib.h>
#import <string.h>
#include "device.h"
#include "mobiledevice.h"

#define is_nil(x) x != (id) [NSNull null] ? YES : NO
#define cstr_ns(x) [NSString stringWithFormat:@"%s", x]

static char *prop_name = NULL;
int device_delayed_unregister_status = 1;
bool device_delayed_unregister_aborted = false;
static struct am_device_notification *device_notification = NULL;
static void (*device_on_connected)(struct am_device *) = NULL;

NSArray *keys = @[@"ActivationState", @"ActivityURL", @"BasebandBootloaderVersion", @"BasebandStatus", @"BasebandVersion", @"BluetoothAddress", @"BuildVersion", @"CPUArchitecture", @"DeviceClass", @"DeviceColor", @"DeviceName", @"FirmwareVersion", @"HardwareModel", @"HardwarePlatform", @"IMLockdownEverRegisteredKey", @"IntegratedCircuitCardIdentity", @"InternationalMobileEquipmentIdentity", @"InternationalMobileSubscriberIdentity", @"iTunesHasConnected",@"MLBSerialNumber", @"MobileSubscriberCountryCode", @"MobileSubscriberNetworkCode", @"ModelNumber", @"PartitionType", @"PhoneNumber", @"ProductType", @"ProductVersion", @"ProtocolVersion", @"RegionInfo", @"SerialNumber", @"SIMStatus", @"SoftwareBundleVersion", @"TimeZone", @"UniqueDeviceID", @"UseActivityURL", @"WeDelivered", @"WiFiAddress"];

NSMutableDictionary *device_info;
bool is_dfu;
bool is_rec;
bool is_normal;

static void device_on_device(struct am_device_notification_callback_info *info, int cookie) {
  if (info->msg == ADNCI_MSG_CONNECTED) {
      is_dfu = false;
      is_rec = false;
      is_normal = true;
      if (device_on_connected != NULL) {
          device_on_connected(info->dev);
      }
  } else if (info->msg == ADNCI_MSG_DISCONNECTED ) {
      is_dfu = false;
      is_rec = false;
      is_normal = false;
  }
}

static void device_delayed_unregister(int64_t timeout) {
  int64_t delay = timeout * 1000000ull;
  dispatch_after(dispatch_time((0ull), delay), dispatch_get_main_queue(), ^{
       if (device_delayed_unregister_aborted == false)
         device_unregister(device_delayed_unregister_status);
     });
}

void device_register(void (*func)(struct am_device *), int64_t timeout) {
  device_on_connected = func;
  AMDeviceNotificationSubscribe(&device_on_device, 0, 0, 0, &device_notification);
  if (timeout <= 0) timeout = DEVICE_DEFAULT_TIMEOUT;
  device_delayed_unregister(timeout);
  CFRunLoopRun();
}

void device_unregister(int status) {
    AMDeviceNotificationUnsubscribe(device_notification);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

void device_connect(struct am_device *device) {
    AMDeviceConnect(device);
    kern_return_t kr;

    kr = AMDeviceIsPaired(device);
    if (kr == KERN_SUCCESS) {
        printf("[*] AMDeviceIsPaired: Success\n");
    } else {
        printf("[*] AMDeviceIsPaired: ERROR - %s\n", mach_error_string(kr));
    }
    kr = AMDeviceValidatePairing(device);
    if (kr == KERN_SUCCESS) {
        printf("[*] AMDeviceValidatePairing: Success\n");
    } else {
        printf("[*] AMDeviceValidatePairin: ERROR - %s\n", mach_error_string(kr));
    }
    kr = AMDeviceStartSession(device);
    if (kr == KERN_SUCCESS) {
        printf("[*] AMDeviceStartSession: Success\n");
    } else {
        printf("[*] AMDeviceStartSession: ERROR - %s\n", mach_error_string(kr));
    }
}

NSString* device_udid(struct am_device *device) {
  return (__bridge NSString*) AMDeviceCopyDeviceIdentifier(device);
}

bool device_matches(struct am_device *device, const char *udid) {
  if (udid == NULL) return true;
  NSString *expected_udid = [NSString stringWithUTF8String:udid];
  NSString *got_udid = device_udid(device);
  return ([got_udid caseInsensitiveCompare:expected_udid] == NSOrderedSame);
}


static void on_device_connected(struct am_device *device) {
    device_delayed_unregister_aborted = true;
    device_info = [NSMutableDictionary new];
    device_connect(device);
    is_dfu = false;
    is_rec = false;
    is_normal = true;
    
    for (id object in keys) {
        prop_name = [object UTF8String];
        NSString *expected_prop_name = [NSString stringWithUTF8String:prop_name];
        CFStringRef key = (__bridge CFStringRef)expected_prop_name;
        id value = AMDeviceCopyValue(device, 0, key);
        
        NSString* format_val = cstr_ns([value UTF8String]);
        NSString* format_key = cstr_ns([object UTF8String]);
        if ([format_val isEqual:@"(null)"]) format_val = @"N/A";

        [device_info setObject:format_val forKey:format_key];
        printf("[*] %s: %s\n", [object UTF8String], [value UTF8String]);
    }


}

static void on_recovery_connected(struct am_recovery_device *device) {
    is_dfu = false;
    is_rec = true;
    is_normal = false;
}

static void on_recovery_disconnected(struct am_recovery_device *device) {
    is_dfu = false;
    is_rec = false;
    is_normal = false;
}

static void on_dfu_connected(struct am_recovery_device *device) {
    is_dfu = true;
    is_rec = false;
    is_normal = false;
}

static void on_dfu_disconnected(struct am_recovery_device *device) {
    is_dfu = false;
    is_rec = false;
    is_normal = false;
}

static void enter_recovery(struct am_device *device) {
    device_delayed_unregister_aborted = true;
    device_connect(device);
    AMDeviceEnterRecovery(device);
    device_unregister(0);
}

void notification(struct am_device_notification_callback_info *info)
{
    
    unsigned int msg = info->msg;
    
    if(msg == ADNCI_MSG_CONNECTED) {
        is_dfu = false;
        is_rec = false;
        is_normal = true;
    } else if ( msg == ADNCI_MSG_DISCONNECTED ) {
        is_dfu = false;
        is_rec = false;
        is_normal = false;
    }
}

void md_register() {
    device_register(on_device_connected, 0);
    mach_error_t ret;
    
    ret = AMDeviceNotificationSubscribe(&device_on_device, 0, 0, 0, &device_notification);
    if(ret < 0) printf("Failed to subscribe for device notifications!\n");
    
    ret = AMRestoreRegisterForDeviceNotifications(on_dfu_connected,on_recovery_connected,on_dfu_disconnected,on_recovery_disconnected,0,NULL);
    if(ret < 0) printf("[md-util] Error failed to register notifications callbacks.\n");
    else printf("[md-util] Notifications callbacks have been set.\n");
    
    CFRunLoopRun();
}

void md_enter_rec() {
    device_register(enter_recovery, 0);
}

void md_unregister() {
    device_unregister(0);
}
