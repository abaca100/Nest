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

#import "MainNavigationController.h"
#import "PHLoadingViewController.h"
#import "PHControlLightsViewController.h"

@interface MainNavigationController ()

@property (nonatomic, strong) PHLoadingViewController *loadingView;
@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;
@property (nonatomic, strong) PHControlLightsViewController *controlLightsViewController;

@end

@implementation MainNavigationController

/*
 * Set the main view controller of the navigation controller
 * depending on whether or not the Nest session is valid.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Create the main view controller in a navigation controller and make the navigation controller the rootviewcontroller of the app
    PHControlLightsViewController *controlLightsViewController = [[PHControlLightsViewController alloc] init];
    
    self.viewControllers = [NSArray arrayWithObject:controlLightsViewController];
}


//#pragma mark - HueSDK
//
///**
// Notification receiver for successful local connection
// */
//- (void)localConnection {
//    // Check current connection state
//    [self checkConnectionState];
//}
//
///**
// Notification receiver for failed local connection
// */
//- (void)noLocalConnection {
//    // Check current connection state
//    [self checkConnectionState];
//}
//
///**
// Notification receiver for failed local authentication
// */
//- (void)notAuthenticated {
//    /***************************************************
//     We are not authenticated so we start the authentication process
//     *****************************************************/
//    
//    // Move to main screen (as you can't control lights when not connected)
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    
//    // Dismiss modal views when connection is lost
//    if (self.navigationController.presentedViewController) {
//        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
//    }
//    
//    // Remove no connection alert
//    [SVProgressHUD dismiss];
//    
//    /***************************************************
//     doAuthentication will start the push linking
//     *****************************************************/
//    
//    // Start local authenticion process
//    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
//}
//
///**
// Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
// */
//- (void)checkConnectionState {
//    if (!self.phHueSDK.localConnected) {
//        // Dismiss modal views when connection is lost
//        
//        if (self.navigationController.presentedViewController) {
//            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
//        }
//        
//        // No connection at all, show connection popup
//        [SVProgressHUD showInfoWithStatus:@"No connection"];
//    }
//    else
//    {
//        // One of the connections is made, remove popups and loading views
//        [SVProgressHUD dismiss];
//    }
//}
//
//
//#pragma mark - Heartbeat control
//
///**
// Starts the local heartbeat with a 10 second interval
// */
//- (void)enableLocalHeartbeat {
//    /***************************************************
//     The heartbeat processing collects data from the bridge
//     so now try to see if we have a bridge already connected
//     *****************************************************/
//    
//    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
//    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
//        //
//        //[self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
//        [SVProgressHUD showInfoWithStatus:@"Connecting..."];
//        
//        // Enable heartbeat with interval of 10 seconds
//        [self.phHueSDK enableLocalConnection];
//    } else {
//        // Automaticly start searching for bridges
//        [self searchForBridgeLocal];
//    }
//}
//
///**
// Stops the local heartbeat
// */
//- (void)disableLocalHeartbeat {
//    [self.phHueSDK disableLocalConnection];
//}
//
//#pragma mark - Bridge searching and selection
//
///**
// Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
// */
//- (void)searchForBridgeLocal {
//    // Stop heartbeats
//    [self disableLocalHeartbeat];
//    
//    // Show search screen
//    //[self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
//    [SVProgressHUD showInfoWithStatus:@"Searching..."];
//    /***************************************************
//     A bridge search is started using UPnP to find local bridges
//     *****************************************************/
//    
//    // Start search
//    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
//    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
//        // Done with search, remove loading view
//        //[self removeLoadingView];
//        [SVProgressHUD dismiss];
//        
//        /***************************************************
//         The search is complete, check whether we found a bridge
//         *****************************************************/
//        
//        // Check for results
//        if (bridgesFound.count > 0) {
//            
//            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
//            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
//            
//            /***************************************************
//             Use the list of bridges, present them to the user, so one can be selected.
//             *****************************************************/
//            
//            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.bridgeSelectionViewController];
//            navController.modalPresentationStyle = UIModalPresentationFormSheet;
//            [self.navigationController presentViewController:navController animated:YES completion:nil];
//        }
//        else {
//            /***************************************************
//             No bridge was found was found. Tell the user and offer to retry..
//             *****************************************************/
//            
//            // No bridges were found, show this to the user
//            [SVProgressHUD showErrorWithStatus:@"Could not find bridge"];
//        }
//    }];
//}
//
///**
// Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
// */
//- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andBridgeId:(NSString *)bridgeId {
//    /***************************************************
//     Removing the selection view controller takes us to
//     the 'normal' UI view
//     *****************************************************/
//    
//    // Remove the selection view controller
//    self.bridgeSelectionViewController = nil;
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    
//    // Show a connecting view while we try to connect to the bridge
//    //[self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
//    [SVProgressHUD show];
//    
//    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
//    //NSString *username = [PHUtilities whitelistIdentifier];
//    
//    /***************************************************
//     Set the ipaddress and bridge id,
//     as the bridge properties that the SDK framework will use
//     *****************************************************/
//    
//    [self.phHueSDK setBridgeToUseWithId:bridgeId ipAddress:ipAddress];
//    
//    /***************************************************
//     Setting the hearbeat running will cause the SDK
//     to regularly update the cache with the status of the
//     bridge resources
//     *****************************************************/
//    
//    // Start local heartbeat again
//    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
//}
//
//#pragma mark - Bridge authentication
//
///**
// Start the local authentication process
// */
//- (void)doAuthentication {
//    // Disable heartbeats
//    [self disableLocalHeartbeat];
//    
//    /***************************************************
//     To be certain that we own this bridge we must manually
//     push link it. Here we display the view to do this.
//     *****************************************************/
//    
//    // Create an interface for the pushlinking
//    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController"
//                                                                                   bundle:[NSBundle mainBundle]
//                                                                                   hueSDK:self.phHueSDK delegate:self];
//    
//    [self.navigationController presentViewController:self.pushLinkViewController animated:YES completion:^{
//        /***************************************************
//         Start the push linking process.
//         *****************************************************/
//        
//        // Start pushlinking when the interface is shown
//        [self.pushLinkViewController startPushLinking];
//    }];
//}
//
///**
// Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
// */
//- (void)pushlinkSuccess {
//    /***************************************************
//     Push linking succeeded we are authenticated against
//     the chosen bridge.
//     *****************************************************/
//    
//    // Remove pushlink view controller
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    self.pushLinkViewController = nil;
//    
//    // Start local heartbeat
//    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
//}
//
///**
// Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
// */
//
//- (void)pushlinkFailed:(PHError *)error {
//    // Remove pushlink view controller
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    self.pushLinkViewController = nil;
//    
//    // Check which error occured
//    if (error.code == PUSHLINK_NO_CONNECTION) {
//        // No local connection to bridge
//        [self noLocalConnection];
//        
//        // Start local heartbeat (to see when connection comes back)
//        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
//    }
//    else {
//        // Bridge button not pressed in time
////        self.authenticationFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
////                                                                    message:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
////                                                                   delegate:self
////                                                          cancelButtonTitle:nil
////                                                          otherButtonTitles:NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"Cancel", @"Authentication failed cancel button"), nil];
////        [self.authenticationFailedAlert show];
//        [SVProgressHUD showErrorWithStatus:@"Make sure you press the button within 30 seconds"];
//    }
//}

@end
