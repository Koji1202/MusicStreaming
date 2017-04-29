//
//  AddMusicController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "AddMusicController.h"
#import "BrowseMusicController.h"
#import "CategoryViewController.h"
#import "GlobalVars.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AddMusicController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation AddMusicController {
    NSInteger nBrowseType;
}

@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationController* nc = (UINavigationController*)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    [nc.navigationBar setBarTintColor:[UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f]];
    nc.navigationBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:56.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
    nc.navigationBar.translucent = FALSE;
    self.title = @"Add Music";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap {
    [self.view endEditing:TRUE];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    nBrowseType = BROWSE_BY_SEARCH;
    [self performSegueWithIdentifier:@"showBrowseMusic" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"Artists Menu";
            break;
        case 1:
            CellIdentifier = @"Albums Menu";
            break;
        case 2:
            CellIdentifier = @"Songs Menu";
            break;
        case 3:
            CellIdentifier = @"Genres Menu";
            break;
        case 4:
            CellIdentifier = @"Composers Menu";
            break;
        case 5:
            CellIdentifier = @"Compilatons Menu";
            break;
        case 6:
            CellIdentifier = @"Playlists Menu";
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:TRUE];
    nBrowseType = indexPath.row;
    [self nextController];
        
}

- (void)nextController {
    if (nBrowseType == BROWSE_BY_SONG || nBrowseType == BROWSE_BY_SEARCH) {
        [self performSegueWithIdentifier:@"showBrowseMusic" sender:self];
    } else {
        NSArray *categoryList;
        switch (nBrowseType) {
            case BROWSE_BY_ARTIST:
                categoryList = [[MPMediaQuery artistsQuery] collections];
                break;
            case BROWSE_BY_ALBUM:
                categoryList = [[MPMediaQuery albumsQuery] collections];
                break;
            case BROWSE_BY_GENRES:
                categoryList = [[MPMediaQuery genresQuery] collections];
                break;
            case BROWSE_BY_COMPOSER:
                categoryList = [[MPMediaQuery composersQuery] collections];
                break;
            case BROWSE_BY_COMPILATION:
                categoryList = [[MPMediaQuery compilationsQuery] collections];
                break;
            case BROWSE_BY_PLAYLIST:
                categoryList = [[MPMediaQuery playlistsQuery] collections];
                break;
            default:
                break;
        }
        if ([categoryList count] == 0) {
            [self performSegueWithIdentifier:@"showBrowseMusic" sender:self];
        } else {
            [self performSegueWithIdentifier:@"showCategory" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showBrowseMusic"]) {
        BrowseMusicController *destController = segue.destinationViewController;
        destController.nBrowseType = nBrowseType;
        if (nBrowseType == BROWSE_BY_SEARCH)
            destController.searchKeyword = searchBar.text;
        else
            destController.searchKeyword = @"";
    }
    if ([segue.identifier isEqualToString:@"showCategory"]) {
        CategoryViewController *destController = segue.destinationViewController;
        destController.nBrowseType = nBrowseType;
    }
}

@end
