//
//  NestStructures.h
//  iOS-NestDK
//
//  Created by Jack lee on 10/27/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

@interface NestStructures : NSObject

@property (nonatomic, strong) NSString *structureId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *country_code;
@property (nonatomic, strong) NSString *time_zone;
@property (nonatomic, strong) NSMutableArray *devices;

@end
