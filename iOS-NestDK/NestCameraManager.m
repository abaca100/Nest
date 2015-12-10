//
//  NestCameraManager.m
//  iOS-NestDK
//
//  Created by Jack Lee on 2015/11/19.
//  Copyright © 2015年 Nest Labs. All rights reserved.
//

#import "NestCameraManager.h"
#import "FirebaseManager.h"

@implementation NestCameraManager


- (void)beginSubscriptionForCamera:(Camera *)camera;
{
    NSString *sid = [NSString stringWithFormat:@"%@", camera.cameraId];
    NSString *str = [NSString stringWithFormat:@"devices/cameras/%@/", sid];
    NSLog(@"path=%@", str);

    NSLog(@"%@.%@ SubscriptionTo 'FirebaseManager'", [[self class] description], NSStringFromSelector(_cmd));

    [[FirebaseManager sharedManager] addSubscriptionToURL:str withBlock:^(FDataSnapshot *snapshot) {
        //NSLog(@"snapshot=%@", snapshot.value);
        NSLog(@"%@.%@ FirebaseManager return  'FDataSnapshot'", [[self class] description], NSStringFromSelector(_cmd));
        [self updateCamera:camera forStructure:snapshot.value];
    }];
}

- (void)updateCamera:(Camera *)camera forStructure:(NSDictionary *)structure
{
    //NSLog(@"camera structure=%@", structure);
    NSLog(@"%@.%@ receive 'Camera Structure'", [[self class] description], NSStringFromSelector(_cmd));
    camera.app_url = [structure objectForKey:@"app_url"];
    camera.web_url = [structure objectForKey:@"web_url"];
    camera.last_is_online_change = [structure objectForKey:@"last_is_online_change"];
    camera.has_motion = [structure objectForKey:@"has_motion"];
    camera.last_event = [structure objectForKey:@"last_event"];
    
    camera.is_online = [[structure objectForKey:@"is_online"] boolValue];
    camera.is_streaming = [[structure objectForKey:@"is_streaming"] boolValue];
    camera.is_video_history_enabled = [[structure objectForKey:@"is_video_history_enabled"] boolValue];
    
    [self.delegate cameraValuesChanged:camera];
}

@end
