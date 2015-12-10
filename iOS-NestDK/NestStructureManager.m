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

#import "NestStructureManager.h"
#import "Thermostat.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"
#import "NestStructures.h"

@implementation NestStructureManager

/**
 * Gets the entire structure and converts it to
 * thermostat objects andreturns it as a dictionary.
 */
- (void)initialize
{
    NSLog(@"%@.%@ SubscriptionTo 'FirebaseManager'", [[self class] description], NSStringFromSelector(_cmd));

    [[FirebaseManager sharedManager] addSubscriptionToURL:@"structures/" withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@.%@ FirebaseManager return 'FDataSnapshot'", [[self class] description], NSStringFromSelector(_cmd));
        [self parseStructure:snapshot.value];
    }];
}

/**
 * Parse the structure and send it back to the delegate
 * @param The structure you want to parse.
 */
- (void)parseStructure:(NSDictionary *)structure
{
    NSLog(@"%@", structure);
    NSArray *thermostats = [self thermostatsForStructure:structure];
    NSArray *models = [self nestStructure:structure];
    
    NSMutableDictionary *returnStructure = [[NSMutableDictionary alloc] init];
    
    if (thermostats) {
        [returnStructure setObject:thermostats forKey:@"thermostats"];
    }
    
    [self.delegate structureUpdated:returnStructure];
    
    
    [self.delegate structureArray:models];

    NSLog(@"%@.%@ delegate to 'Client'", [[self class] description], NSStringFromSelector(_cmd));
}

- (NSArray *)nestStructure:(NSDictionary *)structure
{
    NSMutableArray *m = [[NSMutableArray alloc] initWithCapacity:0];
    for( NSString *aKey in [structure allKeys] )
    {
        NestStructures *nest = [[NestStructures alloc] init];
        NSDictionary *dict = [structure objectForKey:aKey];
        
        if (nest.wheres == nil) {
            nest.wheres = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        nest.structureId = [dict objectForKey:@"structure_id"];
        nest.name = [dict objectForKey:@"name"];
        nest.country_code = [dict objectForKey:@"country_code"];
        nest.time_zone = [dict objectForKey:@"time_zone"];
        
        NSDictionary *wheres = [dict objectForKey:@"wheres"];
        NSArray *keys = [wheres allKeys];
        for (int x=0; x<keys.count; x++)
        {
            NSDictionary *dict_wheres = [wheres objectForKey:keys[x]];
            
            NSString *k1 = keys[x];
            NSString *v1 = [dict_wheres objectForKey:@"name"];
            
            [nest.wheres setObject:v1 forKey:k1];
        }
        
        for( NSString *key in [dict allKeys] )
        {
            if ([@"away" isEqualToString:key])
                continue;
            
            if ([@"structure_id" isEqualToString:key])
                continue;
            
            if ([@"name" isEqualToString:key])
                continue;
            
            if ([@"country_code" isEqualToString:key])
                continue;
            
            if ([@"time_zone" isEqualToString:key])
                continue;
            
            if ([@"wheres" isEqualToString:key])
                continue;
            
            if ([@"rhr_enrollment" isEqualToString:key])
                continue;

            if ([@"smoke_co_alarms" isEqualToString:key])
                continue;
            
            if (nest.devices == nil)
            {
                nest.devices = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            NSLog(@"key=%@", key);
            NSArray *test = [dict objectForKey:key];
            if ((test != nil) && ([test count] > 1))
            {
                long cnt = [test count];
                for (int y=0; y<cnt; y++)
                {
                    NSString *s = [NSString stringWithFormat:@"%@",[[dict objectForKey:key] objectAtIndex:y]];
                    [nest.devices addObject:@{key : s}];
                }
            }
            else
            {
                NSString *s = [NSString stringWithFormat:@"%@",[[dict objectForKey:key] objectAtIndex:0]];
                [nest.devices addObject:@{key : s}];
            }
        }
        [m addObject:nest];
    }
    NSLog(@"%@.%@ get 'NestStructures'", [[self class] description], NSStringFromSelector(_cmd));
    
    return m;
}


/**
 * Create new thermostats for the given structure
 * @param The structure you want to create thermostats for
 * @return The list of thermostats in the structure in an NSArray
 */
- (NSArray *)thermostatsForStructure:(NSDictionary *)structure
{
    NSString *structureId = [[structure allKeys] objectAtIndex:0];
    NSArray *thermostatIds = [[structure objectForKey:structureId] objectForKey:@"thermostats"];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    if (!thermostatIds || [thermostatIds count] == 0) {
        return nil;
    } else {
        for (int i = 0; i < [thermostatIds count]; i++) {
            Thermostat *newThermostat = [[Thermostat alloc] init];
            newThermostat.thermostatId = [thermostatIds objectAtIndex:i];
            [returnArray addObject:newThermostat];
        }
    }
    
    return returnArray;
}

@end
