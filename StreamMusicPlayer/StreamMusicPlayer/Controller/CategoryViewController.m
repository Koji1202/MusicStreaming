//
//  CategoryViewController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/21/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "CategoryViewController.h"
#import "BrowseMusicController.h"
#import "MusicCategoryCell.h"
#import "GlobalVars.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface CategoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *songTblView;
@end

@implementation CategoryViewController {
    NSMutableArray *categoryList;
    NSMutableArray *thumbPath;
    UIActivityIndicatorView *waitPopup;
    NSString *keyWord;
}

@synthesize songTblView;
@synthesize nBrowseType;
@synthesize searchKeyword;
@synthesize navTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    waitPopup = [[GlobalVars sharedInstance] showWaitingDialog:self.view];
    categoryList = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Songs";
    switch (nBrowseType) {
        case BROWSE_BY_ARTIST:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery artistsQuery] collections]];
            break;
        case BROWSE_BY_ALBUM:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery albumsQuery] collections]];
            break;
        case BROWSE_BY_GENRES:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery genresQuery] collections]];
            break;
        case BROWSE_BY_COMPOSER:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery composersQuery] collections]];
            break;
        case BROWSE_BY_COMPILATION:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery compilationsQuery] collections]];
            break;
        case BROWSE_BY_PLAYLIST:
            categoryList = [[NSMutableArray alloc] initWithArray:[[MPMediaQuery playlistsQuery] collections]];
            break;
        default:
            break;
    }
    [songTblView reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categoryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCategoryCell * cell = nil;
    
    NSString *cellid = @"musicCategoryCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"MusicCategoryCell" bundle:nil] forCellReuseIdentifier:cellid];
        cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    }
//    MPMediaItem *category = [[categoryList objectAtIndex:indexPath.row] representativeItem];
    MPMediaItem *category;
    if (nBrowseType == BROWSE_BY_PLAYLIST)
     category = [categoryList objectAtIndex:indexPath.row];
    else
        category = [[categoryList objectAtIndex:indexPath.row] representativeItem];
    
    NSString *title;
    MPMediaItemArtwork *itemArtwork = [category valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artworkUIImage = [itemArtwork imageWithSize:CGSizeMake(44, 44)];
    if (artworkUIImage == nil)
        artworkUIImage = [UIImage imageNamed:@"Music_Default.png"];
    switch (nBrowseType) {
        case BROWSE_BY_ARTIST:
            title = [category valueForProperty:MPMediaItemPropertyArtist];
            break;
        case BROWSE_BY_ALBUM:
            title = [category valueForProperty:MPMediaItemPropertyAlbumTitle];
            break;
        case BROWSE_BY_GENRES:
            title = [category valueForProperty:MPMediaItemPropertyGenre];
            break;
        case BROWSE_BY_COMPOSER:
            title = [category valueForProperty:MPMediaItemPropertyComposer];
            break;
        case BROWSE_BY_COMPILATION:
            title = [category valueForProperty:MPMediaItemPropertyIsCompilation];
            break;
        case BROWSE_BY_PLAYLIST:
            title = [category valueForProperty:MPMediaPlaylistPropertyName];
            break;
    }
    cell.titleView.text = title;
    cell.thumbView.image = artworkUIImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCategoryCell *cell = (MusicCategoryCell *)[tableView cellForRowAtIndexPath:indexPath];
    keyWord = cell.titleView.text;
    [self performSegueWithIdentifier:@"showSongFromCategory" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSongFromCategory"]) {
        BrowseMusicController *destController = segue.destinationViewController;
        destController.nBrowseType = nBrowseType;
        destController.searchKeyword = keyWord;
    }
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
