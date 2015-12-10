/**
 *  Copyright 2014 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import "NestThermostatManager.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"

@interface NestThermostatManager ()

@end

#define FAN_TIMER_ACTIVE @"fan_timer_active"
#define HAS_FAN @"has_fan"
#define TARGET_TEMPERATURE_F @"target_temperature_f"
#define AMBIENT_TEMPERATURE_F @"ambient_temperature_f"
#define TARGET_TEMPERATURE_C @"target_temperature_c"
#define AMBIENT_TEMPERATURE_C @"ambient_temperature_c"
#define NAME_LONG @"name_long"
#define THERMOSTAT_PATH @"devices/thermostats"

@implementation NestThermostatManager

/**
 * Sets up a new Firebase connection for the thermostat provided
 * and observes for any change in /devices/thermostats/thermostatId.
 * @param thermostat The thermostat you want to watch changes for.
 */
- (void)beginSubscriptionForThermostat:(Thermostat *)thermostat
{
    NSString *sid = [NSString stringWithFormat:@"%@", thermostat.thermostatId];
    NSString *str = [NSString stringWithFormat:@"devices/thermostats/%@/", sid];
    //str = @"devices/thermostats";
    NSLog(@"%@.%@ \r\nSubscription 'path=%@'", [[self class] description], NSStringFromSelector(_cmd), str);
    [[FirebaseManager sharedManager] addSubscriptionToURL:str withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@.%@ \r\nFirebase return 'FDataSnapshot=%@'", [[self class] description], NSStringFromSelector(_cmd), snapshot.value);
        [self updateThermostat:thermostat forStructure:snapshot.value];
    }];
}

/**
 * Parse thermostat structure and put it in the thermostat object.
 * Then send the updated object to the delegate.
 * @param thermostat The thermostat you wish to update.
 * @param structure The structure you wish to update the thermostat with.
 */
- (void)updateThermostat:(Thermostat *)thermostat forStructure:(NSDictionary *)structure
{
    NSLog(@"%@.%@ \r\nThermostat receive 'Event'", [[self class] description], NSStringFromSelector(_cmd));
    NSLog(@"Thermost structure=%@", structure);
    if ([structure objectForKey:AMBIENT_TEMPERATURE_F]) {
        thermostat.ambientTemperatureF = [[structure objectForKey:AMBIENT_TEMPERATURE_F] integerValue];
    }
    if ([structure objectForKey:TARGET_TEMPERATURE_F]) {
        thermostat.targetTemperatureF = [[structure objectForKey:TARGET_TEMPERATURE_F] integerValue];
    }
    if ([structure objectForKey:AMBIENT_TEMPERATURE_C]) {
        thermostat.ambientTemperatureC = [[structure objectForKey:AMBIENT_TEMPERATURE_C] integerValue];
    }
    if ([structure objectForKey:TARGET_TEMPERATURE_C]) {
        thermostat.targetTemperatureC = [[structure objectForKey:TARGET_TEMPERATURE_C] integerValue];
    }
    if ([structure objectForKey:HAS_FAN]) {
        thermostat.hasFan = [[structure objectForKey:HAS_FAN] boolValue];

    }
    if ([structure objectForKey:FAN_TIMER_ACTIVE]) {
        thermostat.fanTimerActive = [[structure objectForKey:FAN_TIMER_ACTIVE] boolValue];

    }
    if ([structure objectForKey:NAME_LONG]) {
        thermostat.nameLong = [structure objectForKey:NAME_LONG];
    }
    
    [self.delegate thermostatValuesChanged:thermostat];
}

/**
 * Sets the thermostat values by using the Firebase API.
 * @param thermostat The thermost you wish to save.
 * @see https://www.firebase.com/docs/transactions.html
 */
- (void)saveChangesForThermostat:(Thermostat *)thermostat
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    [values setValue:[NSNumber numberWithInteger:thermostat.targetTemperatureC] forKey:TARGET_TEMPERATURE_C];
    [values setValue:[NSNumber numberWithBool:thermostat.fanTimerActive] forKey:FAN_TIMER_ACTIVE];
    
    NSString *str = [NSString stringWithFormat:@"%@/%@/", THERMOSTAT_PATH, thermostat.thermostatId];
    //NSString *str = [NSString stringWithFormat:@"%@/%@/", THERMOSTAT_PATH, @"NzI7ZPCEGKwInf9jB6OtOdAuWoZvpauT"];
    NSLog(@"str=%@", str);
    [[FirebaseManager sharedManager] setValues:values forURL:str];
    
//    // IMPORTANT to set withLocalEvents to NO
//    // Read more here: https://www.firebase.com/docs/transactions.html
//    [self.fireBase runTransactionBlock:^FTransactionResult *(FMutableData *currentData) {
//        [currentData setValue:values];
//        return [FTransactionResult successWithValue:currentData];
//    } andCompletionBlock:^(NSError *error, BOOL committed, FDataSnapshot *snapshot) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        }
//    } withLocalEvents:NO];
}



@end
