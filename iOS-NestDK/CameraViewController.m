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

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.nestCameraManager = [[NestCameraManager alloc] init];
    [self.nestCameraManager setDelegate:self];
    self.webview.delegate = self;
    [self.is_event setOn:NO];
    self.last_event.text = self.last_event1.text = @"";
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
    [SVProgressHUD show];
    if ([camera.cameraId isEqualToString:[self.currentCamera cameraId]])
    {
        // update
        self.last_update.text = camera.last_is_online_change;
        urlStr = camera.app_url;
        webStr = camera.web_url;
        
        NSLog(@"camera.last_event=%@", camera.last_event);
        NSDictionary *event = camera.last_event;
        

        [self.is_event setOn:[[event objectForKey:@"has_motion"] boolValue]];
        if (self.is_event) {
            [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(turnOff:)
                                           userInfo:nil
                                            repeats:NO];

            self.last_event.text = [NSString stringWithFormat:@"Motion start: %@", [event objectForKey:@"start_time"] ];
            self.last_event1.text = [NSString stringWithFormat:@"Motion end: %@", [event objectForKey:@"end_time"] ];
        }
        else
        {
            self.last_event1.text = @"";
            self.last_event.text = @"";
        }
        
        
//        self.last_event.text = camera.last_is_online_change;
//        self.last_event.text = [event objectForKey:@"end_time"];
//        if (self.last_event.text == nil) {
//            self.last_event.text = [event objectForKey:@"start_time"];
//        }
        
        if (camera.is_streaming) {
            self.title = @"Camera";
        } else {
            self.title = @"Camera is off";
        }
        //NSLog(@"%@", [event objectForKey:@"image_url"]);
        
        //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:webStr]];
        //[self.webview loadRequest:request];
    }
    [SVProgressHUD dismiss];
}

- (IBAction)turnOff:(id)sender
{
    [self.is_event setOn:NO];
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
    
    if ([self getCurrentThermost])
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

- (BOOL)getCurrentThermost
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
