/**
 * @class      SimplePlayerViewController SimplePlayerViewController.m "SimplePlayerViewController.m"
 * @brief      A Player that can be used to simply load an embed code and play it
 * @details    SimplePlayerViewController in Ooyala Sample Apps
 * @date       12/12/14
 * @copyright  Copyright (c) 2014 Ooyala, Inc. All rights reserved.
 */


#import "IMACustomConfiguredPlayerViewController.h"
#import <OoyalaSDK/OoyalaSDK.h>
#import <OoyalaIMASDK/OOIMAManager.h>
#import <OoyalaIMASDK/OOIMAConfiguration.h>
#import "AppDelegate.h"

@interface IMACustomConfiguredPlayerViewController ()
@property OOOoyalaPlayerViewController *ooyalaPlayerViewController;
@property (nonatomic) OOIMAManager *adsManager;
@property NSString *embedCode;
@property NSString *nib;
@property NSString *pcode;
@property NSString *playerDomain;
@end

@implementation IMACustomConfiguredPlayerViewController{
  AppDelegate *appDel;
}

- (id)initWithPlayerSelectionOption:(PlayerSelectionOption *)playerSelectionOption {
  self = [super initWithPlayerSelectionOption: playerSelectionOption];
  self.nib = @"PlayerSimple";

  if (self.playerSelectionOption) {
    self.embedCode = self.playerSelectionOption.embedCode;
    self.title = self.playerSelectionOption.title;
    self.pcode = self.playerSelectionOption.pcode;
    self.playerDomain = self.playerSelectionOption.domain;
  } else {
    NSLog(@"There was no PlayerSelectionOption!");
    return nil;
  }
  return self;
}

- (void)loadView {
  [super loadView];
  [[NSBundle mainBundle] loadNibNamed:self.nib owner:self options:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  appDel = [[UIApplication sharedApplication] delegate];

  // Create Ooyala ViewController
  OOOoyalaPlayer *player = [[OOOoyalaPlayer alloc] initWithPcode:self.pcode domain:[[OOPlayerDomain alloc] initWithString:self.playerDomain]];
  self.ooyalaPlayerViewController = [[OOOoyalaPlayerViewController alloc] initWithPlayer:player];

  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector:@selector(notificationHandler:)
                                               name:nil
                                             object:_ooyalaPlayerViewController.player];

  // Attach it to current view
  [self addChildViewController:_ooyalaPlayerViewController];
  [self.playerView addSubview:_ooyalaPlayerViewController.view];
  [self.ooyalaPlayerViewController.view setFrame:self.playerView.bounds];

  //Create an optional OOIMAConfiguration
  OOIMAConfiguration *config = [OOIMAConfiguration new];
  config.localeOverride = @"fr";
  
  self.adsManager = [[OOIMAManager alloc] initWithOoyalaPlayer:player configuration:config];

  // Override the ad url to load when a video is loaded
  [self.adsManager setAdUrlOverride:@"http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/7521029/pb_test_mid&ciu_szs=640x480&impl=s&cmsid=949&vid=FjbGRjbzp0DV_5-NtXBVo5Rgp3Sj0R5C&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]"];


  // Load the video
  [_ooyalaPlayerViewController.player setEmbedCode:self.embedCode];
  [_ooyalaPlayerViewController.player play];
}

- (void) notificationHandler:(NSNotification*) notification {

  // Ignore TimeChangedNotificiations for shorter logs
  if ([notification.name isEqualToString:OOOoyalaPlayerTimeChangedNotification]) {
    return;
  }

  NSLog(@"Notification Received: %@. state: %@. playhead: %f count: %d",
        [notification name],
        [OOOoyalaPlayer playerStateToString:[self.ooyalaPlayerViewController.player state]],
        [self.ooyalaPlayerViewController.player playheadTime], appDel.count);
  appDel.count++;
}

@end
