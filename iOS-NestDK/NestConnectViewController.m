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

#import "NestConnectViewController.h"
#import "UIColor+Custom.h"
#import "NestAuthManager.h"
#import "NestWebViewAuthController.h"
#import "NestControlsViewController.h"
#import "ECSlidingViewController.h"

@interface NestConnectViewController () <NestWebViewAuthControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *nestConnectButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NestWebViewAuthController *nestWebViewAuthController;
@property (nonatomic, strong) NSTimer *checkTokenTimer;

@end

@implementation NestConnectViewController

#pragma mark View Setup Methods

/**
 * Setup the view.
 */
//- (void)loadView
//{
//    // Setup the view itself
//    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    
//    // Add a scrollview just to feel a little nicer
//    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
//    [self.scrollView setBounces:YES];
//    [self.scrollView setAlwaysBounceVertical:YES];
//    [self.view addSubview:self.scrollView];
//    
//    // Add the button the scrollview
//    self.nestConnectButton = [self createNestConnectButton];
//    [self.nestConnectButton setFrame:CGRectMake(35, CGRectGetMidY(self.scrollView.bounds) - self.nestConnectButton.frame.size.height, self.nestConnectButton.frame.size.width, self.nestConnectButton.frame.size.height)];
//    [self.scrollView addSubview:self.nestConnectButton];
//}

/**
 * Create the nest connect button.
 * @return The new nest connect button.
 */
- (void)createNestConnectButton
{
    [_nestConnectButton setTitleColor:[UIColor nestBlue] forState:UIControlStateNormal];
    [_nestConnectButton setTitleColor:[UIColor nestBlueSelected] forState:UIControlStateHighlighted];
    
    [_nestConnectButton setTitle:@"Connect with your nest account!" forState:UIControlStateNormal];
    
    [_nestConnectButton.titleLabel setNumberOfLines:4];
    [_nestConnectButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_nestConnectButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0.0, 00.0)];
    
    [_nestConnectButton.layer setBorderColor:[UIColor nestBlue].CGColor];
    [_nestConnectButton.layer setCornerRadius:8.f];
    [_nestConnectButton.layer setBorderWidth:3.f];
    [_nestConnectButton.layer setMasksToBounds:YES];
    
    [_nestConnectButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:33]];
    [_nestConnectButton addTarget:self action:@selector(nestConnectButtonHit:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 * Called when the nest connect button is hit.
 * Presents the web auth URL.
 * @param sender The button that sent the message.
 */
- (void)nestConnectButtonHit:(UIButton *)sender
{
    // First we need to create the authorization_code URL
//    NSString *authorizationCodeURL = [[NestAuthManager sharedManager] authorizationURL];
//    NSLog(@"authorizationCodeURL=%@", authorizationCodeURL);
//    [self presentWebViewWithURL:authorizationCodeURL];
}


/**
 * Present the web view with the given url.
 * @param url The url you wish to have the web view load.
 */
- (void)presentWebViewWithURL:(NSString *)url
{
    // Present modally the web view controller
//    self.nestWebViewAuthController = [[NestWebViewAuthController alloc] initWithURL:url delegate:self];
//    [self presentViewController:self.nestWebViewAuthController animated:YES completion:^{}];
}

/**
 * Checks periodically every second after the authorization code is received to
 * see if it has been exchanged for the access token.
 * @param The timer that sent the message.
 */
- (void)checkForAccessToken:(NSTimer *)sender
{
    if ([[NestAuthManager sharedManager] isValidSession])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        ECSlidingViewController *mnc = [storyboard instantiateViewControllerWithIdentifier:@"ECSliding"];
        
//        NestControlsViewController *ncvc = [[NestControlsViewController alloc] init];
        [self presentViewController:mnc animated:YES completion:nil];
//        [self.navigationController setViewControllers:[NSArray arrayWithObject:mnc] animated:YES];
    }
    else
    {
        [self.nestConnectButton setEnabled:YES];
        [self.nestConnectButton setTitle:@"Connect with your nest account!" forState:UIControlStateNormal];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pincode"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];

    }
    [self invalidateTimer];
}

#pragma mark ViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the nav bar title
    self.title = @"Welcome";
    
    //[self.nestConnectButton setEnabled:YES];
    [self createNestConnectButton];
}

#pragma mark NestWebViewControllerDelegate Methods

/**
 * Called from the NestWebViewControllerDelegate
 * if the user successfully finds the authorization code.
 * @param authorizationCode The authorization code NestAuthManager found.
 */
- (void)foundAuthorizationCode:(NSString *)authorizationCode
{
    [self.nestWebViewAuthController dismissViewControllerAnimated:YES completion:^{}];
    
    // Save the authorization code
    [[NestAuthManager sharedManager] setAuthorizationCode:authorizationCode];
    
    // Check for the access token every second and once we have it leave this page
    [self setupcheckTokenTimer];
    
    // Set the button to disabled
    [self.nestConnectButton setEnabled:NO];
    [self.nestConnectButton setTitle:@"Loading..." forState:UIControlStateNormal];
}

/**
 * Called from the NestWebViewControllerDelegate if the user hits cancel
 * @param sender The button that sent the message.
 */
- (void)cancelButtonHit:(UIButton *)sender
{
    [self.nestWebViewAuthController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Private Methods

/**
 * Invalidate the check token timer
 */
- (void)invalidateTimer
{
    if ([self.checkTokenTimer isValid]) {
        [self.checkTokenTimer invalidate];
        self.checkTokenTimer = nil;
    }
}

/**
 * Setup the checkTokenTimer
 */
- (void)setupcheckTokenTimer
{
    [self invalidateTimer];
    self.checkTokenTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkForAccessToken:) userInfo:nil repeats:YES];
}


 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    
    if ([segue.identifier isEqualToString:@"itri_auth"])
    {
        NSString *authorizationCodeURL = [[NestAuthManager sharedManager] authorizationURL];
        
        UINavigationController *nc = [segue destinationViewController];
        NestWebViewAuthController *dest = (NestWebViewAuthController *)nc.topViewController;
        dest.authURL = authorizationCodeURL;
    }
}


- (IBAction)inputAuthorizationCode:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter the Pincode"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    alert.alertViewStyle= UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView textFieldAtIndex:0] != nil)
    {
        [self foundAuthorizationCode:[[alertView textFieldAtIndex:0] text]];
    }
}

@end
