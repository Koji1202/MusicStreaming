//
//  VoteViewController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/25/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "VoteViewController.h"
#import "MusicAddViewCell.h"
#import "VoteListTask.h"
#import "GlobalVars.h"
#import "SideMenu.h"

@interface VoteViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *songListView;
@end

@implementation VoteViewController {
    NSMutableArray *songList;
    VoteListTask *listTask;
    UIActivityIndicatorView *waitPopup;
    SideMenu *menuView;
}

@synthesize songListView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    listTask = [[VoteListTask alloc] init];
    waitPopup = [[GlobalVars sharedInstance] showWaitingDialog:self.view];
    [listTask sendRequest:[GlobalVars sharedInstance].userId Response:^(int code ,NSMutableArray *result){
        [waitPopup stopAnimating];
        if (code == ERR_OK) {
            songList = [[NSMutableArray alloc] initWithArray:result];
            if ([songList count] == 0) {
                [waitPopup stopAnimating];
            } else {
                
            }
            [songListView reloadData];
        } else {
            [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
        }
    }];
    
    menuView = (SideMenu *)[[[NSBundle mainBundle] loadNibNamed:@"SideMenuView" owner:self options:nil] objectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [menuView setFrame:CGRectMake(-self.view.bounds.size.width / 4 * 3, 0, self.view.bounds.size.width / 3 * 2, self.navigationController.view.frame.size.height)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:menuView];
    [menuView hideView];
    menuView.hidden = TRUE;
    
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onHomeClick)];
    [menuView.homeView addGestureRecognizer:homeTap];
    UITapGestureRecognizer *likeTap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onLikeClick)];
    [menuView.likeView addGestureRecognizer:likeTap];
}

- (void)viewWillDisappear:(BOOL)animated {
    [menuView removeFromSuperview];
}

- (void)onHomeClick {
    [self performSegueWithIdentifier:@"showMain" sender:self];
}
- (void)onLikeClick {
    [menuView hideView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [songList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicAddViewCell * cell = nil;
    
    NSString *cellid = @"musicAddViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"MusicAddViewCell" bundle:nil] forCellReuseIdentifier:cellid];
        cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    }
    
    NSDictionary *song = [songList objectAtIndex:indexPath.row];
    cell.titleView.text = [song objectForKey:@"title"];
    NSString *artist = [song objectForKey:@"artist"];
    if (artist == nil) artist = @"";
    NSString *album = [song objectForKey:@"album"];
    if (album == nil) album = @"";
    [GlobalVars loadImageFromUrl:cell.thumbView FileName:[song objectForKey:@"thumb"] defaultImage:[UIImage imageNamed:@"Music_Default.png"]];
    if (![artist isEqualToString:@""]) {
        if ([album isEqualToString:@""])
            cell.infoView.text = artist;
        else
            cell.infoView.text = [NSString stringWithFormat:@"%@ - %@", artist, album];
    } else {
        cell.infoView.text = album;
    }
    return cell;
}
- (IBAction)menuAction:(id)sender {
    [menuView showView:self.view.bounds.size.width / 4 * 3];

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
