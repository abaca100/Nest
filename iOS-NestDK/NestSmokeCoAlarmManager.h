//
//  NestSmokeCoAlarmManager.h
//  iOS-NestDK
//
//  Created by Jack lee on 10/29/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

#import "SmokeCoAlarm.h"

@protocol NestSmokeCoAlarmManagerDelegate <NSObject>

- (void)thermostatValuesChanged:(SmokeCoAlarm *)smokecoalarm;

@end

@interface NestSmokeCoAlarmManager : NSObject

@property (nonatomic, strong) id <NestSmokeCoAlarmManagerDelegate>delegate;

- (void)beginSubscriptionForThermostat:(SmokeCoAlarm *)smokecoalarm;

@end
