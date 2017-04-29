//
//  FirstViewController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "FirstViewController.h"
#import "GlobalVars.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UINavigationController* nc = (UINavigationController*)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    nc.navigationBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:56.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
    nc.navigationBar.translucent = FALSE;
    [self.navigationController setNavigationBarHidden:YES animated:TRUE];
    
    [GlobalVars sharedInstance].songList = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
