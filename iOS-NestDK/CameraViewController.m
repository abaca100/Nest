//
//  CameraViewController.m
//  iOS-NestDK
//
//  Created by Jack Lee on 2015/11/19.
//  Copyright © 2015年 Nest Labs. All rights reserved.
//

#import "CameraViewController.h"
#import "NestCameraManager.h"
#import "NestStructures.h"
#import <HueSDK_iOS/HueSDK.h>
#import "FirebaseManager.h"

#define MAX_HUE 65535

@interface CameraViewController () <NestCameraManagerDelegate, UIWebViewDelegate>
{
    NSString *urlStr;
    NSString *webStr;
}

@property (nonatomic, strong) NestCameraManager *nestCameraManager;
@property (nonatomic, strong) Camera *currentCamera;
@property (nonatomic, strong) NSArray *currentStructure;

@property (nonatomic, weak)   IBOutlet UILabel *last_update;
@property (nonatomic, weak)   IBOutlet UIWebView *webview;
@property (nonatomic, weak)   IBOutlet UISwitch *is_event;
@property (nonatomic, weak)   IBOutlet UILabel *last_event;
@property (nonatomic, weak)   IBOutlet UILabel *last_event1;
@property (nonatomic, weak)   IBOutlet UIView *hue_container;
@property (nonatomic, weak)   IBOutlet UISwitch *light_on;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"%@.%@ initialize 'NestCameraManager'", [[self class] description], NSStringFromSelector(_cmd));

    self.nestCameraManager = [[NestCameraManager alloc] init];
    [self.nestCameraManager setDelegate:self];
    self.webview.delegate = self;
    [self.is_event setOn:NO];
    self.last_event.text = self.last_event1.text = @"";
    
    self.hue_container.layer.cornerRadius = 10;
    self.hue_container.layer.masksToBounds = YES;
    self.hue_container.layer.borderColor =[UIColor whiteColor].CGColor;
    self.hue_container.layer.borderWidth = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [self structureLoading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NestCameraManagerDelegate Methods

- (void)cameraValuesChanged:(Camera *)camera
{
    NSLog(@"%@.%@ delegate update 'UI'", [[self class] description], NSStringFromSelector(_cmd));

    [SVProgressHUD show];
    if ([camera.cameraId isEqualToString:[self.currentCamera cameraId]])
    {
        // update
        self.last_update.text = [self currentDatetime:camera.last_is_online_change];
        urlStr = camera.app_url;
        webStr = camera.web_url;
        
        NSLog(@"camera.last_event=%@", camera.last_event);
        NSDictionary *event = camera.last_event;
        

        [self.is_event setOn:[[event objectForKey:@"has_motion"] boolValue]];
        if (self.is_event)
        {
            NSString *s_time = [self currentDatetime:[event objectForKey:@"start_time"]];
            NSString *e_time = [self currentDatetime:[event objectForKey:@"end_time"]];
            
            if (([s_time length] > 0) && ([e_time length] > 0))
            {
                self.last_event.text =  [NSString stringWithFormat:@"Motion start: %@", s_time];
                self.last_event1.text = [NSString stringWithFormat:@"Motion end  : %@", e_time];
                [self.is_event setOn:NO];
            }
            if (([s_time length] > 0) && ([e_time length] == 0))
            {
                self.last_event.text =  [NSString stringWithFormat:@"Motion start: %@", s_time];
                self.last_event1.text = @"";
                [self.is_event setOn:YES];
            }
            else
            {
                [self.is_event setOn:NO];
            }
        }
        else
        {
            self.last_event1.text = @"";
            self.last_event.text = @"";
        }
        
        
        if (camera.is_streaming)
        {
            //[[self hue_container] setHidden:YES];
            self.title = @"Camera";
            [self turnLights:NO];
        }
        else
        {
            //[[self hue_container] setHidden:NO];
            self.title = @"Camera is off";
            [self turnLights:YES];
        }
    }
    [SVProgressHUD dismiss];
}

- (NSString *)currentDatetime:(NSString *)str
{
    if (str == nil)
        return @"";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *date = [dateFormat dateFromString:str];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormat stringFromDate:date];
}

- (BOOL)turnLights:(BOOL)state
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];

    if (!(cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil))
    {
        [[self hue_container] setHidden:YES];
        return false;
    }
    
    for (PHLight *light in cache.lights.allValues)
    {
        PHLightState *lightState = light.lightState;
        
        if (state) {
            lightState.on = @YES;
            [[self light_on] setOn:YES];
        } else {
            lightState.on = @NO;
            [[self light_on] setOn:NO];
        }

        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors)
        {
            if (errors != nil)
            {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
                [[self light_on] setOn:NO];
            }
            else
            {
                if (state && ([lightState.reachable intValue] == 1)) {
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

                        NSLog(@"%@.%@ \r\nlight.identifier:%@ 'lightState=%@'", [[self class] description], NSStringFromSelector(_cmd), light.identifier, lightState);

                        if ([@"1" isEqualToString:light.identifier]) {
                            lightState.x = [NSNumber numberWithDouble:0.675];
                            lightState.y = [NSNumber numberWithDouble:0.322];
                        } else if ([@"2" isEqualToString:light.identifier]) {
                            lightState.x = [NSNumber numberWithDouble:0.41];
                            lightState.y = [NSNumber numberWithDouble:0.517];
                        } else if ([@"3" isEqualToString:light.identifier]) {
                            lightState.x = [NSNumber numberWithDouble:0.1691];
                            lightState.y = [NSNumber numberWithDouble:0.0441];
                        }
                        
                        lightState.ct = @500;
                        
                        if ([lightState.on intValue] == 1) {
                            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:nil];
                        }
                    });
                    
                }
            }
            
        }];
    }
    
    return self.light_on.on;
}

- (IBAction)swithc_light:(id)sender
{
    if (self.light_on.on == YES)
    {
        NSNumber *num = [[NSNumber alloc] initWithInt:1];
        if ([self turnLights:num] == NO)
        {
            [SVProgressHUD showErrorWithStatus:@"Turn-on light failure."];
        }
    }
    else
    {
        [self turnLights:0];
    }
}

- (void)subscribeToCamera:(Camera *)camera
{
    // See if the structure has any thermostats --
    if (camera) {
        
        // Update the current thermostats
        //self.currentThermostat = thermostat;
        
        // Load information for just the first thermostat
        [self.nestCameraManager beginSubscriptionForCamera:camera];
        
    }
    
}

- (IBAction)open:(id)sender
{
    NSString *str = [NSString stringWithFormat:@"%@&appname=APPNAME&backlink=CUSTOM_SCHEME://BACKLINK_PATH", urlStr];
    NSLog(@"%@\n%@", str, urlStr);
    NSURL *myURL = [NSURL URLWithString:str];
    [[UIApplication sharedApplication] openURL:myURL];
}

- (void)structureLoading
{
    NSData *objData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NEST"];
    NSArray *structure = [NSKeyedUnarchiver unarchiveObjectWithData:objData];
    
    self.currentStructure = structure;
    
    if ([self getCurrentCamera])
    {
        self.title = @"Camera";
        [self subscribeToCamera:self.currentCamera];
    }
    else
    {
        self.title = @"You don't have any Nest Camera devices";
        [SVProgressHUD dismiss];
    }
}

- (BOOL)getCurrentCamera
{
    for (int i=0; i<self.currentStructure.count; i++)
    {
        NestStructures *nest = self.currentStructure[i];
        
        for (int j=0; j<nest.devices.count; j++)
        {
            NSDictionary *dict = nest.devices[j];
            NSArray *values = [dict allValues];
            
            for (int k=0; k<values.count; k++)
            {
                NSString *str = [NSString stringWithFormat:@"%@", values[k]];
                if ([self.camerasId isEqualToString:str])
                {
                    Camera *c = [[Camera alloc] init];
                    c.cameraId = self.camerasId;
                    self.currentCamera = c;
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    NSLog(@"%@", error);
}


- (IBAction)refresh:(id)sender
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];

    NSLog(@"_currentCamera.is_streaming=%d", _currentCamera.is_streaming);
    _currentCamera.is_streaming = !_currentCamera.is_streaming;
    NSLog(@"_currentCamera.is_streaming=%d", _currentCamera.is_streaming);
    [values setValue:[NSNumber numberWithBool:_currentCamera.is_streaming] forKey:@"is_streaming"];
    
    NSString *str = [NSString stringWithFormat:@"devices/cameras/%@/", _currentCamera.cameraId];
    NSLog(@"str=%@", str);
    [[FirebaseManager sharedManager] setValues:values forURL:str];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
