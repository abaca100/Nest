//
//  Camera.h
//  iOS-NestDK
//
//  Created by Jack Lee on 2015/11/19.
//  Copyright © 2015年 Nest Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Camera : NSObject

@property (nonatomic, strong) NSString *cameraId;
@property (nonatomic, strong) NSString *nameLong;
@property (nonatomic)         BOOL is_online;
@property (nonatomic)         BOOL is_streaming;
@property (nonatomic)         BOOL is_video_history_enabled;
@property (nonatomic, strong) NSString *web_url;
@property (nonatomic, strong) NSString *app_url;
@property (nonatomic, strong) NSString *last_is_online_change;
@property (nonatomic, strong) NSString *has_motion;
@property (nonatomic, strong) NSMutableDictionary *last_event;

@end
