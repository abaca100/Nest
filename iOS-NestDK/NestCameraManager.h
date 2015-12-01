//
//  NestCameraManager.h
//  iOS-NestDK
//
//  Created by Jack Lee on 2015/11/19.
//  Copyright © 2015年 Nest Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"

@protocol NestCameraManagerDelegate <NSObject>

- (void)cameraValuesChanged:(Camera *)camera;

@end

@interface NestCameraManager : NSObject

@property (nonatomic, strong) id <NestCameraManagerDelegate>delegate;

- (void)beginSubscriptionForCamera:(Camera *)camera;

@end
