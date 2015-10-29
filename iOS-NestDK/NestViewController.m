//
//  NestViewController.m
//  iOS-NestDK
//
//  Created by Jack lee on 10/26/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

#import "NestViewController.h"
//#import "NestThermostatManager.h"
#import "NestStructureManager.h"
#import "Thermostat.h"
#import "NestStructures.h"

@interface NestViewController () <NestStructureManagerDelegate>

@property (nonatomic, strong) NestStructureManager *nestStructureManager;
@property (nonatomic, strong) IBOutlet UITextView *struc;

@end

@implementation NestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Nest Development";

    // Get the initial structure
    self.nestStructureManager = [[NestStructureManager alloc] init];
    [self.nestStructureManager setDelegate:self];
    [self.nestStructureManager initialize];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - NestStructureManagerDelegate Methods

/**
 * Called from NestStructureManagerDelegate, lets the
 * controller know the structure has changed.
 * @param structure The updated structure.
 */
- (void)structureUpdated:(NSDictionary *)structure
{
//    NSMutableString *s = [[NSMutableString alloc] initWithCapacity:0];
//    [structure enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
//        //NSLog(@"%@ = %@", key, object);
//        [s appendString:object];
//    }];
    NSLog(@"structure=%@", structure);
}

- (void)structureArray:(NSArray *)structure
{
    NSMutableString *s = [[NSMutableString alloc] initWithCapacity:0];
    for (int k=0; k<structure.count; k++) {
        NestStructures *n = structure[k];
        [s appendString:@"Data Model:\n\t"];
//        [s appendString:n.structureId];
//        [s appendString:@"\n\t"];
        [s appendString:n.name];
        [s appendString:@"\n\t"];
        [s appendString:n.country_code];
        [s appendString:@"\n\t"];
        [s appendString:n.time_zone];
        [s appendString:@"\n\t"];
        
        [s appendString:@"Devices:\n"];
        for (int i=0; i<n.devices.count; i++) {
            [s appendString:@"\t\t"];
            
            NSArray *dev1 = [n.devices[i] allKeys];
            //NSArray *aObj = [n.devices[i] objectForKey:dev1[0]];
            
            //[s appendString:[NSString stringWithFormat:@"%@: %lu", dev1[0], aObj.count]];
            
//            NSString *x = [n.devices[i] objectForKey:dev1[0]];
//            [s appendString:[NSString stringWithFormat:@"%@ - %@", dev1[0], x]];
            [s appendString:[NSString stringWithFormat:@"%@", dev1[0]]];
            [s appendString:@"\n"];
        }
        
        [s appendString:@"------------------------------\n\n"];
    }
    
    NSData* objData = [NSKeyedArchiver archivedDataWithRootObject:structure];
    [[NSUserDefaults standardUserDefaults] setObject:objData forKey:@"NEST"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _struc.text = s;
    
    [SVProgressHUD dismiss];
}

@end
