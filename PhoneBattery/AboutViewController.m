//
//  AboutViewController.m
//  PhoneBattery
//
//  Created by Marcel Voß on 21.09.15.
//  Copyright © 2015 Marcel Voss. All rights reserved.
//

#import "AboutViewController.h"

#import "PhoneBattery-Swift.h"

static NSString *twitterURL = @"http://twitter.com/uimarcel";
static NSString *twitterPBURL = @"https://twitter.com/phonebatteryapp";
static NSString *gitHubURL = @"https://github.com/marcelvoss/PhoneBattery";
static NSString *appStoreURL = @"https://itunes.apple.com/us/app/phonebattery-your-phones-battery/id1009278300?ls=1&mt=8";

@interface AboutViewController () <MFMailComposeViewControllerDelegate, WCSessionDelegate>
{
    UIVisualEffectView *introVisualEffectView;
    WCSession *session;
    BatteryInformation *batteryInformation;
}

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     batteryInformation = [BatteryInformation new];
    
    if ([WCSession isSupported]) {
        session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        [self sendInformationToWatch];
    }

    
    self.title = NSLocalizedString(@"WELCOME", nil);
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.86 blue:0.55 alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.window.tintColor = [UIColor colorWithRed:0 green:0.86 blue:0.55 alpha:1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed:)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:batteryInformation.device];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChanged:) name:UIDeviceBatteryStateDidChangeNotification object:batteryInformation.device];
    
    
    [self setupViews];
}

- (void)setupViews
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundImage"]];
    backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, headerView.frame.size.height);
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:backgroundImageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = backgroundImageView.frame;
    [backgroundImageView addSubview:visualEffectView];
    
    UIImageView *appIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MaskedIcon"]];
    appIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [visualEffectView addSubview:appIconImageView];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:appIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:visualEffectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:appIconImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:visualEffectView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-20]];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:appIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:75]];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:appIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:75]];
    
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"PhoneBattery";
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView addSubview:nameLabel];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:visualEffectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-7]];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:appIconImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:20]];
    
    
    NSDictionary *versionDictionary = [DeviceInformation appIdentifiers];
     
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)",
                         versionDictionary[@"shortString"], versionDictionary[@"buildString"]];
    versionLabel.font = [UIFont systemFontOfSize:13];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView addSubview:versionLabel];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:versionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [visualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:versionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:nameLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    
    self.tableView.tableHeaderView = headerView;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"]) {
        [self showIntroduction];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Introduction

- (void)showIntroduction
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    introVisualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    introVisualEffectView.frame = [[UIScreen mainScreen] bounds];
    introVisualEffectView.alpha = 0;
    [self.navigationController.view.window addSubview:introVisualEffectView];
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, screenHeight * 3);
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [introVisualEffectView addSubview:scrollView];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    
    UILabel *firstDescription = [UILabel new];
    firstDescription.translatesAutoresizingMaskIntoConstraints = NO;
    firstDescription.textColor = [UIColor whiteColor];
    firstDescription.textAlignment = NSTextAlignmentCenter;
    firstDescription.numberOfLines = 0;
    firstDescription.font = [UIFont systemFontOfSize:18];
    firstDescription.text = NSLocalizedString(@"INTRODUCTION_DESCRIPTION_1", nil);
    [scrollView addSubview:firstDescription];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstDescription attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstDescription attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:20]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstDescription attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-80]];
    
    
    UILabel *firstTitle = [UILabel new];
    firstTitle.translatesAutoresizingMaskIntoConstraints = NO;
    firstTitle.textColor = [UIColor whiteColor];
    firstTitle.textAlignment = NSTextAlignmentCenter;
    firstTitle.numberOfLines = 0;
    firstTitle.font = [UIFont boldSystemFontOfSize:25];
    firstTitle.text = NSLocalizedString(@"INTRODUCTION_GREETING", nil);
    [scrollView addSubview:firstTitle];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:firstDescription attribute:NSLayoutAttributeTop multiplier:1.0 constant:-20]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:firstTitle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-80]];
    
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WatchImage1"]];
    imageView1.translatesAutoresizingMaskIntoConstraints = NO;
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView1];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-50 + screenHeight]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:200]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:200]];
    
    
    UILabel *scrollLabel1 = [UILabel new];
    scrollLabel1.text = NSLocalizedString(@"SWIPE_UP", comment: nil);
    scrollLabel1.textColor = [UIColor whiteColor];
    scrollLabel1.textAlignment = NSTextAlignmentCenter;
    scrollLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:scrollLabel1];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollLabel1 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:15]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollLabel1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:(screenHeight * 1) - 25]];
    
    
    UIImageView *arrow1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowIcon"]];
    arrow1.translatesAutoresizingMaskIntoConstraints = NO;
    arrow1.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:arrow1];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow1 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:scrollLabel1 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-15]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollLabel1 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:18]];
    
    
    
    UILabel *scrollLabel2 = [UILabel new];
    scrollLabel2.text = NSLocalizedString(@"SWIPE_UP", comment: nil);
    scrollLabel2.textColor = [UIColor whiteColor];
    scrollLabel2.textAlignment = NSTextAlignmentCenter;
    scrollLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:scrollLabel2];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollLabel2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:15]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:scrollLabel2 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:(screenHeight * 2) - 25]];
    
    UIImageView *arrow2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowIcon"]];
    arrow2.translatesAutoresizingMaskIntoConstraints = NO;
    arrow2.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:arrow2];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow2 attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:scrollLabel2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-15]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollLabel2 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:arrow2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:18]];
    
    
    UILabel *secondDescription = [UILabel new];
    secondDescription.translatesAutoresizingMaskIntoConstraints = NO;
    secondDescription.textColor = [UIColor whiteColor];
    secondDescription.textAlignment = NSTextAlignmentCenter;
    secondDescription.numberOfLines = 0;
    secondDescription.font = [UIFont systemFontOfSize:18];
    secondDescription.text = NSLocalizedString(@"INTRODUCTION_DESCRIPTION_2", nil);
    [scrollView addSubview:secondDescription];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:secondDescription attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:secondDescription attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView1 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:secondDescription attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-80]];
    
    
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WatchImage2"]];
    imageView2.translatesAutoresizingMaskIntoConstraints = NO;
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView2];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-50 + screenHeight * 2]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:200]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:imageView2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:200]];
    
    UILabel *thirdDescription = [UILabel new];
    thirdDescription.translatesAutoresizingMaskIntoConstraints = NO;
    thirdDescription.textColor = [UIColor whiteColor];
    thirdDescription.textAlignment = NSTextAlignmentCenter;
    thirdDescription.numberOfLines = 0;
    thirdDescription.font = [UIFont systemFontOfSize:18];
    thirdDescription.text = NSLocalizedString(@"INTRODUCTION_DESCRIPTION_3", nil);
    [scrollView addSubview:thirdDescription];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:thirdDescription attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:thirdDescription attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageView2 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:thirdDescription attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:introVisualEffectView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-80]];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:NSLocalizedString(@"CLOSE", nil) forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    closeButton.layer.cornerRadius = 14;
    closeButton.layer.masksToBounds = YES;
    [closeButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closeIntroduction) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:closeButton];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:45]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-30 + screenHeight * 3]];
    
    [introVisualEffectView addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-40]];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        introVisualEffectView.alpha = 1;
    }];
}

- (void)closeIntroduction
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        introVisualEffectView.alpha = 0;
    } completion:^(BOOL finished) {
        [introVisualEffectView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selectors

- (void)sharePressed:(id)sender
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:@[NSLocalizedString(@"SHARE_TITLE", nil),
                                                                    [NSURL URLWithString:appStoreURL]] applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"GENERAL", nil).uppercaseString;
    } else if (section == 1) {
        return NSLocalizedString(@"WHO_MADE_THIS", nil).uppercaseString;
    } else if (section == 2) {
        return NSLocalizedString(@"MORE", nil).uppercaseString;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        
        UILabel *thanksLabel = [UILabel new];
        thanksLabel.translatesAutoresizingMaskIntoConstraints = NO;
        thanksLabel.text = NSLocalizedString(@"THANKS_DOWNLOADING", nil);
        thanksLabel.textAlignment = NSTextAlignmentCenter;
        thanksLabel.font = [UIFont systemFontOfSize:12];
        thanksLabel.numberOfLines = 0;
        thanksLabel.textColor = [UIColor colorWithRed:0.46 green:0.46 blue:0.48 alpha:1];
        [headerView addSubview:thanksLabel];
        
        [headerView addConstraint:[NSLayoutConstraint constraintWithItem:thanksLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        [headerView addConstraint:[NSLayoutConstraint constraintWithItem:thanksLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:5]];
        
        [headerView addConstraint:[NSLayoutConstraint constraintWithItem:thanksLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-50]];
        
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 75;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    CreatorTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier2"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
        cell2 = [[CreatorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier2"];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"SUPPORT", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"INTRODUCTION", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"RATE_ON_STORE", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell2.nameLabel.text = @"Marcel Voss";
            cell2.jobLabel.text = NSLocalizedString(@"JOB_TITLE", nil);
            cell2.avatarImageView.image = [UIImage imageNamed:@"MarcelAvatar"];
            return cell2;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"PB_TWITTER", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1){
            cell.textLabel.text = NSLocalizedString(@"AVAILABLE_GITHUB", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
                mailComposer.mailComposeDelegate = self;
                mailComposer.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.86 blue:0.55 alpha:1];
                
                UIDevice *device = [UIDevice currentDevice];
                NSDictionary *identifierDictionary = [DeviceInformation appIdentifiers];
                NSString *subjectString = [NSString stringWithFormat:@"Support for PhoneBattery %@ (%@)",
                                           identifierDictionary[@"shortString"], identifierDictionary[@"buildString"]];
                NSString *bodyString = [NSString stringWithFormat:@"\n\n\n-----\niOS Version: %@\nDevice: %@\n", device.systemVersion, [DeviceInformation hardwareIdentifier]];
                
                [mailComposer setMessageBody:bodyString isHTML:NO];
                [mailComposer setSubject:subjectString];
                [mailComposer setToRecipients:@[@"help@marcelvoss.com"]];
                
                [self presentViewController:mailComposer animated:YES completion:nil];
            }
            
            if (![session isWatchAppInstalled]) {
                
            }
            
        } else if (indexPath.row == 1) {
            [self showIntroduction];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else if (indexPath.row == 2) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreURL]];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:twitterURL]];
            [self presentViewController:safariVC animated:YES completion:nil];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:twitterPBURL]];
            [self presentViewController:safariVC animated:YES completion:nil];
        } else if (indexPath.row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:gitHubURL]];
            [self presentViewController:safariVC animated:YES completion:nil];
        }
    }
}

#pragma mark - NSNotificationCenter Selectors

- (void)batteryLevelChanged:(NSNotification *)notification
{
    [self sendInformationToWatch];
}

- (void)batteryStateChanged:(NSNotification *)notification
{
    [self sendInformationToWatch];
}

#pragma mark - WatchConnectivity Methods

- (void)sendInformationToWatch
{
    NSNumber *batteryLevel = [NSNumber numberWithInteger:[batteryInformation currentBatteryLevel]];
    NSNumber *batteryState = [NSNumber numberWithInt:batteryInformation.currentBatteryState];
    
    NSError *connectivityError = nil;
    NSDictionary *applicationDictionary = @{@"batteryLevel": batteryLevel,
                                            @"batteryState": batteryState,
                                            @"batteryStateString": [BatteryInformation
                                                                    stringForBatteryState:batteryInformation.currentBatteryState]};
    [session updateApplicationContext:applicationDictionary error:&connectivityError];
    
    if (connectivityError != nil) {
        // TODO: Handle error here
        NSLog(@"Watch Connectivity Error: %@", connectivityError.localizedDescription);
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext
{
    
}


@end
