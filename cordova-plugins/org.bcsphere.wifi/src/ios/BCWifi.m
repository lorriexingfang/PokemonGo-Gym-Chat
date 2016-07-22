/*
 Copyright 2013-2014 JUMA Technology
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "BCWifi.h"

@implementation BCWifi

- (NSString *)getIP {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

- (id)getSSIDinfo{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}

- (void)getConnectedWifiInfo:(CDVInvokedUrlCommand*)command{
    CDVPluginResult* pluginResult = nil;
    NSString* ipaddr = [self getIP];
    NSMutableDictionary *dicInfo = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* dicSSID = [self getSSIDinfo];
    [dicInfo setObject:[NSString stringWithFormat:@"%@",ipaddr] forKey:@"IPAddress"];
    [dicInfo setObject:[NSString stringWithFormat:@"%@",[dicSSID objectForKey:@"BSSID"]] forKey:@"BSSID"];
    [dicInfo setObject:[NSString stringWithFormat:@"%@",[dicSSID objectForKey:@"SSID"]] forKey:@"SSID"];
    [dicInfo setObject:@"" forKey:@"MacAddress"];
    if (ipaddr != nil && ![ipaddr isEqualToString:@"error"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dicInfo];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end

