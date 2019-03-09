//
//  AppDelegate.m
//  CloseInnerScreenApp
//
//  Created by weixin on 3/8/19.
//  Copyright © 2019 weixin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSMenu *statusMenu;
// 状态栏图标
@property (strong) NSImage *statusImage;
// 状态栏
@property (strong) NSStatusItem *statusItem;

@property (assign) float preBrinessLevel;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self setMainStatus];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void)setMainStatus {
    self.statusImage = [NSImage imageNamed:@"screen"];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem.button setImage:self.statusImage];
    [self.statusItem setMenu:self.statusMenu];
}

- (IBAction)toggleInnerScreen:(NSMenuItem*)sender {
    float innerScreenBrightnessLevel = [self getScreenBrightnessLevel];
    if (innerScreenBrightnessLevel < 0.5) {
        [self openScreen];
        [sender setTitle:@"(Close Inner Screen)关闭内建显示器"];
    } else {
        [self closeScreen];
        [sender setTitle:@"(Open Inner Screen)开启内建显示器"];
    }
}
- (IBAction)BuyMeACoffee:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/ruandao/CloseInnerScreen"]];
}

- (IBAction)feedback:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/ruandao/CloseInnerScreen/issues"]];
}

- (IBAction)exit:(id)sender {
    [NSApp terminate:self];
}

- (float)getScreenBrightnessLevel {
    float level;
    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);
    
    // If we were successful
    if (result == kIOReturnSuccess)
    {
        io_object_t service;
        while ((service = IOIteratorNext(iterator))) {
            IODisplayGetFloatParameter(service, kNilOptions, CFSTR(kIODisplayBrightnessKey), &level);
            // Let the object go
            IOObjectRelease(service);
            return level;
        }
    }
    return 1;
}

- (void)setScreenBrightnessLevel:(float)level {
    
    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);
    
    // If we were successful
    if (result == kIOReturnSuccess)
    {
        io_object_t service;
        while ((service = IOIteratorNext(iterator))) {
            IODisplaySetFloatParameter(service, kNilOptions, CFSTR(kIODisplayBrightnessKey), level);
            
            // Let the object go
            IOObjectRelease(service);
            
            return;
        }
    }
}
- (void)openScreen {
    [self setScreenBrightnessLevel:self.preBrinessLevel];
}

- (void)closeScreen {
    self.preBrinessLevel = [self getScreenBrightnessLevel];
    [self setScreenBrightnessLevel:0];
}

@end
