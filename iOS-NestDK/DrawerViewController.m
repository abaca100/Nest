//
//  DrawerViewController.m
//  iOS-NestDK
//
//  Created by Jack lee on 10/28/15.
//  Copyright © 2015 Nest Labs. All rights reserved.
//

#import "DrawerViewController.h"
#import "UIViewController+ECSlidingViewController.h"
#import "MEDynamicTransition.h"
#import "METransitions.h"

@interface DrawerViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *btn_drawer;
@property (nonatomic, strong) METransitions *transitions;
@property (nonatomic, strong) UIPanGestureRecognizer *dynamicTransitionPanGesture;

@end

@implementation DrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_btn_drawer setTarget:self];
    [_btn_drawer setAction:@selector(menuButtonTapped:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

- (METransitions *)transitions
{
    if (_transitions) return _transitions;
    
    _transitions = [[METransitions alloc] init];
    
    return _transitions;
}

- (UIPanGestureRecognizer *)dynamicTransitionPanGesture
{
    if (_dynamicTransitionPanGesture) return _dynamicTransitionPanGesture;
    
    _dynamicTransitionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.transitions.dynamicTransition action:@selector(handlePanGesture:)];
    
    return _dynamicTransitionPanGesture;
}

- (IBAction)menuButtonTapped:(id)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
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
