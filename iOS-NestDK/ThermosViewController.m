//
//  ThermosViewController.m
//  iOS-NestDK
//
//  Created by Jack lee on 10/28/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

#import "ThermosViewController.h"
#import "ThermostatView.h"
#import "NestThermostatManager.h"
#import "NestStructures.h"

@interface ThermosViewController () <NestThermostatManagerDelegate>

// Thermos View Outlet
@property (nonatomic, strong) IBOutlet UILabel *currentTempLabel;
@property (nonatomic, strong) IBOutlet UILabel *targetTempLabel;
@property (nonatomic, strong) IBOutlet UIButton *thermostatNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *currentTempSuffix;
@property (nonatomic, strong) IBOutlet UILabel *targetTempSuffix;
@property (nonatomic, strong) IBOutlet UILabel *fanSuffix;
@property (nonatomic, strong) IBOutlet UISlider *tempSlider;
@property (nonatomic, strong) IBOutlet UISwitch *fanSwitch;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIView *controlPanel;

// Controls
@property (nonatomic, strong) NestThermostatManager *nestThermostatManager;
@property (nonatomic, strong) Thermostat *currentThermostat;
@property (nonatomic, strong) NSArray *currentStructure;

@property (nonatomic) BOOL isSlidingSlider;

@end

#define FAN_TIMER_SUFFIX_ON @"fan timer (on)"
#define FAN_TIMER_SUFFIX_OFF @"fan timer (off)"
#define FAN_TIMER_SUFFIX_DISABLED @"fan timer (disabled)"
//#define TEMP_MIN_VALUE 50
//#define TEMP_MAX_VALUE 90
#define TEMP_MIN_VALUE 10
#define TEMP_MAX_VALUE 32


@implementation ThermosViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Nest Thermos Controls";

    self.nestThermostatManager = [[NestThermostatManager alloc] init];
    [self.nestThermostatManager setDelegate:self];
    
    [self.controlPanel.layer setCornerRadius:6.f];
    [self.controlPanel.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.controlPanel.layer setBorderWidth:1.f];
    [self.controlPanel.layer setMasksToBounds:YES];

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

- (void)structureLoading
{
    NSData *objData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NEST"];
    NSArray *structure = [NSKeyedUnarchiver unarchiveObjectWithData:objData];

    self.currentStructure = structure;
    self.controlPanel.hidden = NO;
    
    if ([self getCurrentThermost])
    {
        [self subscribeToThermostat:self.currentThermostat];
        [self.statusLabel setText:@"Nest Thermostat Control Panel"];
    }
    else
    {
        self.controlPanel.hidden = YES;
        [self.statusLabel setText:@"You don't have any Nest Thermostat devices"];
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
                if ([self.thermostatsId isEqualToString:str])
                {
                    Thermostat *t = [[Thermostat alloc] init];
                    t.thermostatId = self.thermostatsId;
                    self.currentThermostat= t;
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

#pragma mark - ThermostatViewDelegate Methods

/**
 * Called from the ThermostatViewDelegate, lets the controller know
 * thermostat info has changed.
 * @param thermostat The updated thermostat object from ThermostatView.
 */
- (void)thermostatInfoChange:(Thermostat *)thermostat
{
    [self.nestThermostatManager saveChangesForThermostat:thermostat];
}


/**
 * Setup the communication between thermostatView and thermostatControl.
 * @param thermostat The thermostat you wish to subscribe to.
 */
- (void)subscribeToThermostat:(Thermostat *)thermostat
{
    // See if the structure has any thermostats --
    if (thermostat) {
        
        // Update the current thermostats
        //self.currentThermostat = thermostat;
        
        // Load information for just the first thermostat
        [self.nestThermostatManager beginSubscriptionForThermostat:thermostat];
        
    }
    
}


#pragma mark - NestThermostatManagerDelegate Methods

- (void)thermostatValuesChanged:(Thermostat *)thermostat
{
    if ([thermostat.thermostatId isEqualToString:[self.currentThermostat thermostatId]]) {
        [self updateWithThermostat];
    }
    [SVProgressHUD dismiss];
}

- (void)updateWithThermostat
{
    // Update the name of the thermostat
    [self.thermostatNameLabel setTitle:self.currentThermostat.nameLong forState:UIControlStateNormal];
    
    // Update the current temp label
    self.currentTempLabel.text = [NSString stringWithFormat:@"%d°", (int)self.currentThermostat.ambientTemperatureC];
    self.targetTempLabel.text = [NSString stringWithFormat:@"%d°", (int)self.currentThermostat.targetTemperatureC];
    [self equalizeSlider];
    

    // If the thermostat isn't associated with a fan -- turn off the switch
    if (self.currentThermostat.hasFan) {
        [self.fanSwitch setEnabled:YES];
        [self.fanSwitch  setOn:self.currentThermostat.fanTimerActive];
        
        if (self.currentThermostat.fanTimerActive) {
            [self.fanSuffix setText:FAN_TIMER_SUFFIX_ON];
        } else {
            [self.fanSuffix setText:FAN_TIMER_SUFFIX_OFF];
        }
    } else {
        [self.fanSwitch setEnabled:NO];
        [self.fanSuffix setText:FAN_TIMER_SUFFIX_DISABLED];
    }
}

- (void)equalizeSlider
{
    int range = (TEMP_MAX_VALUE - TEMP_MIN_VALUE);
    int relative = (int)self.currentThermostat.targetTemperatureC - TEMP_MIN_VALUE;
    float percent = (float)relative/(float)range;
    
    if (!self.isSlidingSlider) {
        [self animateSliderToValue:percent];
    }
}

- (void)animateSliderToValue:(float)value
{
    [UIView animateWithDuration:.5 animations:^{
        [self.tempSlider setValue:value animated:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.targetTempLabel.text = [NSString stringWithFormat:@"%ld°", (long)[self tempSliderActualValue]];
}

- (NSInteger)tempSliderActualValue
{
    float percent = self.tempSlider.value;
    int range = TEMP_MAX_VALUE - TEMP_MIN_VALUE;
    int relative = round(range * percent);
    return relative + TEMP_MIN_VALUE;
}

- (IBAction)sliderMoving:(UISlider *)sender
{
    self.isSlidingSlider = YES;
}

- (IBAction)sliderValueSettled:(UISlider *)sender
{
    self.isSlidingSlider = NO;
    
    [self.currentThermostat setTargetTemperatureC:[self tempSliderActualValue]];
    [self saveThermostatChange];
}

- (void)saveThermostatChange
{
    [self thermostatInfoChange:self.currentThermostat];
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
