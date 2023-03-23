//
//  YZHViewController.m
//  YZHCocoaLumberjack
//
//  Created by yinzhihao on 03/22/2023.
//  Copyright (c) 2023 yinzhihao. All rights reserved.
//

#import "YZHViewController.h"
#import <YZHCocoaLumberjack/YZHCocoaLumberjack.h>

@interface YZHViewController ()

@end

@implementation YZHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    DDLogError(@"DDLogError");
    DDLogWarn(@"DDLogWarn");
    DDLogInfo(@"DDLogInfo");
    DDLogDebug(@"DDLogDebug");
    
    YZHLogError(@"YZHLogError");
    YZHLogWarn (@"YZHLogWarn");
    YZHLogInfo(@"YZHLogInfo");
    YZHLogDebug(@"YZHLogDebug");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
