//
//  NestStructures.m
//  iOS-NestDK
//
//  Created by Jack lee on 10/27/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

#import "NestStructures.h"

@implementation NestStructures


- (void) encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_structureId forKey:@"structureId"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_time_zone forKey:@"time_zone"];
    [encoder encodeObject:_country_code forKey:@"country_code"];
    [encoder encodeObject:_devices forKey:@"devices"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _structureId = [coder decodeObjectForKey:@"structureId"];
        _name = [coder decodeObjectForKey:@"name"];
        _time_zone = [coder decodeObjectForKey:@"time_zone"];
        _country_code = [coder decodeObjectForKey:@"country_code"];
        _devices = [coder decodeObjectForKey:@"devices"];
    }
    return self;
}
@end
