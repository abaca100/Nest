// MEMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MEMenuViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MainNavigationController.h"
#import "NestStructures.h"
#import "ThermosViewController.h"
#import "CameraViewController.h"
#import "NestViewController.h"

@interface MEMenuViewController ()
{
    NSManagedObjectContext *moc;
}

@property (nonatomic, strong) NSMutableArray *menuItems;
@property (nonatomic, strong) UINavigationController *transitionsNavigationController;
@end

@implementation MEMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // topViewController is the transitions navigation controller at this point.
    // It is initially set as a User Defined Runtime Attributes in storyboards.
    // We keep a reference to this instance so that we can go back to it without losing its state.
    self.transitionsNavigationController = (UINavigationController *)self.slidingViewController.topViewController;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self blurBg];
}

- (void)blurBg
{
    self.headbg.backgroundColor = [UIColor lightGrayColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.headbg.frame;
    
    [self.headbg addSubview:visualEffectView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSData *objData = [[NSUserDefaults standardUserDefaults] objectForKey:@"NEST"];
    _menuItems = [NSKeyedUnarchiver unarchiveObjectWithData:objData];
    
    NestStructures *struc = [[NestStructures alloc] init];
    struc.name = @"Hue";
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_menuItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NestStructures *nest = _menuItems[section];
    return [nest.devices count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NestStructures *nest = _menuItems[section];
    return nest.name;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NestStructures *nest = _menuItems[indexPath.section];
    NSDictionary *dict = nest.devices[indexPath.row];
    NSArray *values = [dict allKeys];
    cell.textLabel.text = [NSString stringWithFormat:@"\t%@", values[0]];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
    NestStructures *nest = _menuItems[indexPath.section];
    NSDictionary *dict = nest.devices[indexPath.row];
    NSArray *values = [dict allKeys];
    NSString *str = [NSString stringWithFormat:@"%@", values[0]];
    
    if ([@"thermostats" isEqualToString:str])
    {
        UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"itri_thermos"];
        ThermosViewController *thermos = (ThermosViewController *)nc.topViewController;
        NSString *thermostatsId = [NSString stringWithFormat:@"%@", [dict objectForKey:str]];
        thermos.thermostatsId = thermostatsId;
        NSLog(@"thermostatsId=%@", thermostatsId);
        self.slidingViewController.topViewController = nc;
    }
    else if ([@"cameras" isEqualToString:str])
    {
        UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"itri_camera"];
        CameraViewController *camera = (CameraViewController *)nc.topViewController;
        NSString *camerasId = [NSString stringWithFormat:@"%@", [dict objectForKey:str]];
        camera.camerasId = camerasId;
        NSLog(@"camerasId=%@", camerasId);
        self.slidingViewController.topViewController = nc;
    }
    else
    {
        //self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"entry_point"];
    }
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
