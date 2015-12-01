/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import "PHBridgeSelectionViewController.h"
#import "PHBridgePushLinkViewController.h"
#import "PHLoadingViewController.h"
#import "PHControlLightsViewController.h"
#import <HueSDK_iOS/HueSDK.h>
#define MAX_HUE 65535

@class PHHueSDK;

@interface PHControlLightsViewController() <PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate>

@property (nonatomic,weak) IBOutlet UILabel *bridgeIdLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeLastHeartbeatLabel;
@property (nonatomic,weak) IBOutlet UIButton *randomLightsButton;

@property (strong, nonatomic) PHHueSDK *phHueSDK;
@property (nonatomic, strong) PHLoadingViewController *loadingView;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;
@property (nonatomic, strong) PHControlLightsViewController *controlLightsViewController;

@end


@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Find bridge" style:UIBarButtonItemStylePlain target:self action:@selector(findNewBridgeButtonAction)];
    
    self.navigationItem.title = @"QuickStart";
    
    [self noLocalConnection];
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.text = @"Not connected";
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.text = @"Not connected";
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeIdLabel.text = @"Not connected";
    [self.bridgeIdLabel setEnabled:NO];
    
    [self.randomLightsButton setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.text = cache.bridgeConfiguration.ipaddress;
        
        // Set the identifier of the bridge
        self.bridgeIdLabel.text = cache.bridgeConfiguration.bridgeId;
        
        // Check if we are connected to the bridge right now
        if (self.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            
            [self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.text = @"Waiting...";
            [self.randomLightsButton setEnabled:NO];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    //[self searchForBridgeLocal];
}

- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}

- (void)findNewBridgeButtonAction{
//    [self searchForBridgeLocal];
}


#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
//- (void)localConnection {
//    // Check current connection state
//    [self checkConnectionState];
//}

/**
 Notification receiver for failed local connection
 */
//- (void)noLocalConnection {
//    // Check current connection state
//    [self checkConnectionState];
//}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    // Move to main screen (as you can't control lights when not connected)
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Dismiss modal views when connection is lost
    if (self.navigationController.presentedViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // Remove no connection alert
//    if (self.noConnectionAlert != nil) {
//        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
//        self.noConnectionAlert = nil;
//    }
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        // Dismiss modal views when connection is lost
        
        if (self.navigationController.presentedViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        
        // No connection at all, show connection popup
        
//        if (self.noConnectionAlert == nil) {
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            
//            // Showing popup, so remove this view
//            [self removeLoadingView];
//            [self showNoConnectionDialog];
//        }
        
    }
    else {
        // One of the connections is made, remove popups and loading views
        
//        if (self.noConnectionAlert != nil) {
//            [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
//            self.noConnectionAlert = nil;
//        }
        [self removeLoadingView];
        
    }
}

/**
 Shows the first no connection alert with more connection options
 */
- (void)showNoConnectionDialog {
    
//    self.noConnectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No connection", @"No connection alert title")
//                                                        message:NSLocalizedString(@"Connection to bridge is lost", @"No Connection alert message")
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:NSLocalizedString(@"Reconnect", @"No connection alert reconnect button"), NSLocalizedString(@"Find new bridge", @"No connection find new bridge button"),NSLocalizedString(@"Cancel", @"No connection cancel button"), nil];
//    self.noConnectionAlert.tag = 1;
//    [self.noConnectionAlert show];
    
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        //
        [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Show search screen
    [self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        // Done with search, remove loading view
        [self removeLoadingView];
        
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            
            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
            
            /***************************************************
             Use the list of bridges, present them to the user, so one can be selected.
             *****************************************************/
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.bridgeSelectionViewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
            
//            self.noBridgeFoundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No bridges", @"No bridge found alert title")
//                                                                 message:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")
//                                                                delegate:self
//                                                       cancelButtonTitle:nil
//                                                       otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"),NSLocalizedString(@"Cancel", @"No bridge found alert cancel button"), nil];
//            self.noBridgeFoundAlert.tag = 1;
//            [self.noBridgeFoundAlert show];
        }
    }];
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId {
    /***************************************************
     Removing the selection view controller takes us to
     the 'normal' UI view
     *****************************************************/
    
    // Remove the selection view controller
    self.bridgeSelectionViewController = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    // Show a connecting view while we try to connect to the bridge
    [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
    
    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
    //NSString *username = [PHUtilities whitelistIdentifier];
    
    /***************************************************
     Set the ipaddress and bridge id,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [self.phHueSDK setBridgeToUseWithId:bridgeId ipAddress:ipAddress];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the
     bridge resources
     *****************************************************/
    
    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    /***************************************************
     To be certain that we own this bridge we must manually
     push link it. Here we display the view to do this.
     *****************************************************/
    
    // Create an interface for the pushlinking
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController" bundle:[NSBundle mainBundle] hueSDK:self.phHueSDK delegate:self];
    
    [self.navigationController presentViewController:self.pushLinkViewController animated:YES completion:^{
        /***************************************************
         Start the push linking process.
         *****************************************************/
        
        // Start pushlinking when the interface is shown
        [self.pushLinkViewController startPushLinking];
    }];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against
     the chosen bridge.
     *****************************************************/
    
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */

- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
//        self.authenticationFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
//                                                                    message:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
//                                                                   delegate:self
//                                                          cancelButtonTitle:nil
//                                                          otherButtonTitles:NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"Cancel", @"Authentication failed cancel button"), nil];
//        [self.authenticationFailedAlert show];
    }
}


#pragma mark - Loading view

/**
 Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
 @param text The text to display under the spinner
 */
- (void)showLoadingViewWithText:(NSString *)text {
    // First remove
    [self removeLoadingView];
    
    // Then add new
    self.loadingView = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    self.loadingView.view.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.loadingView.view];
    self.loadingView.loadingLabel.text = text;
}

/**
 Removes the full screen loading overlay.
 */
- (void)removeLoadingView {
    if (self.loadingView != nil) {
        [self.loadingView.view removeFromSuperview];
        self.loadingView = nil;
    }
}

@end
