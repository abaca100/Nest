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

@interface MEMenuViewController ()
{
    NSManagedObjectContext *moc;
}

@property (nonatomic, strong) NSArray *menuItems;
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

//    AppDelegate *kAppDelegate = [[UIApplication sharedApplication] delegate];
//    moc = [kAppDelegate managedObjectContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)blurBg
{
    self.headbg.backgroundColor = [UIColor grayColor];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.headbg.frame;
    
    [self.headbg addSubview:visualEffectView];
}


#pragma mark - Properties

- (NSArray *)menuItems
{
    if (_menuItems) return _menuItems;
    
//    NSError *anyError;
//    NSFetchRequest *r_tutor = [NSFetchRequest fetchRequestWithEntityName:@"Tutor"];
//    NSArray *matchingTutor = [moc executeFetchRequest:r_tutor error:&anyError];
//
//    for (int i=0; i<[matchingTutor count]; i++)
//    {
//        Tutor *t = matchingTutor[i];
//        NSLog(@"%@ - %@", t.sid, t.last_name);
//    }
//    _menuItems = matchingTutor;
//    NSLog(@"%lu",(unsigned long)[matchingTutor count]);
    _menuItems = @[@"Your Move",
                   @"Their Move",
                   @"Won Games",
                   @"Lost Games",
                   @"Options"];
    
    return _menuItems;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *t1 = self.menuItems[indexPath.row];

    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.text = t1;
    
//    NSString *url = [NSString stringWithFormat:BaseURL, t1.img];
//    [cell.imageView setImageWithURL:[NSURL URLWithString: url]];
//    [self maskProfileImage:cell.imageView];
    
    return cell;
}

- (void)maskProfileImage:(UIImageView *)imgV
{
    imgV.layer.cornerRadius = imgV.frame.size.width / 2;
    imgV.layer.borderWidth = 0.8f;
    imgV.layer.borderColor = [UIColor whiteColor].CGColor;
    imgV.clipsToBounds = YES;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // This undoes the Zoom Transition's scale because it affects the other transitions.
    // You normally wouldn't need to do anything like this, but we're changing transitions
    // dynamically so everything needs to start in a consistent state.
    self.slidingViewController.topViewController.view.layer.transform = CATransform3DMakeScale(1, 1, 1);
    
//    Tutor *t1 = self.menuItems[indexPath.row];

    if ([self.slidingViewController.topViewController.childViewControllers[0] isKindOfClass:[MainNavigationController class]])
    {
        //MainNavigationController *v1 = ((MainNavigationController *)self.slidingViewController.topViewController.childViewControllers[0]);
    }
    
    [self.slidingViewController resetTopViewAnimated:YES];
}

@end
