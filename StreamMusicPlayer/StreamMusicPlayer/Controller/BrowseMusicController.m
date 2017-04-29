//
//  BrowseMusicController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "BrowseMusicController.h"
#import "MusicAddViewCell.h"
#import "GlobalVars.h"
#import "UploadFileTask.h"
#import "UploadMusicTask.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface BrowseMusicController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *songTblView;
@end

@implementation BrowseMusicController {
    NSMutableArray *songList;
    NSMutableArray *thumbPath;
    UIActivityIndicatorView *waitPopup;
    NSMutableArray *checkedIndexPaths;
    NSMutableArray *letterArr;
    UploadFileTask *uploadTask;
    UploadMusicTask *musicTask;
}

@synthesize songTblView;
@synthesize nBrowseType;
@synthesize searchKeyword;
@synthesize navTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    waitPopup = [[GlobalVars sharedInstance] showWaitingDialog:self.view];
    uploadTask = [[UploadFileTask alloc] init];
    musicTask = [[UploadMusicTask alloc] init];
    checkedIndexPaths = [[NSMutableArray alloc] init];
    songList = [[NSMutableArray alloc] init];
    letterArr = [[NSMutableArray alloc] initWithArray:@[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"]];
    [songTblView setSectionIndexColor:[UIColor colorWithRed:139.0f/255.0f green:56.0f/255.0f blue:160.f/255.0f alpha:1.0f]];
    songTblView.allowsMultipleSelection = TRUE;
    [waitPopup startAnimating];
    
    switch (nBrowseType) {
        case BROWSE_BY_SEARCH:
            self.title = @"Search";
            break;
        case BROWSE_BY_SONG:
            self.title = @"Songs";
            break;
        case BROWSE_BY_ARTIST:
            self.title = @"Artists";
            break;
        case BROWSE_BY_ALBUM:
            self.title = @"Albums";
            break;
        case BROWSE_BY_GENRES:
            self.title = @"Genres";
            break;
        case BROWSE_BY_COMPOSER:
            self.title = @"Composers";
            break;
        case BROWSE_BY_COMPILATION:
            self.title = @"Compilations";
            break;
        case BROWSE_BY_PLAYLIST:
            self.title = @"Playlists";
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableArray<MPMediaItem *> *tmpList;
    
    MPMediaPropertyPredicate *predicate = nil;
    if (searchKeyword != nil && ![searchKeyword isEqualToString:@""]) {
        switch (nBrowseType) {
        case BROWSE_BY_ARTIST:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyArtist];
            break;
        case BROWSE_BY_ALBUM:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyAlbumTitle];
            break;
        case BROWSE_BY_SONG:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyTitle];
            break;
        case BROWSE_BY_GENRES:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyGenre];
            break;
        case BROWSE_BY_COMPOSER:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyComposer];
            break;
        case BROWSE_BY_COMPILATION:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyIsCompilation];
            break;
        case BROWSE_BY_PLAYLIST:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaPlaylistPropertyName];
            break;
        case BROWSE_BY_SEARCH:
            predicate = [MPMediaPropertyPredicate predicateWithValue:searchKeyword forProperty:MPMediaItemPropertyTitle];
            break;
        default:
            break;
        }
    }
    
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    if (predicate != nil)
        [query addFilterPredicate:predicate];
    tmpList = [[NSMutableArray alloc] initWithArray:[query items]];
    
    for (int i = [letterArr count] - 2; i >= 0; i--) { // Z -> A
        NSMutableArray *partList = [[NSMutableArray alloc] init];
        for (int j = 0; j < [tmpList count]; j++) {
            MPMediaItem *song = [tmpList objectAtIndex:j];
            NSString *title = [song valueForProperty: MPMediaItemPropertyTitle];
            NSString *prefix = [[title substringToIndex:1] uppercaseString];
            NSComparisonResult result = [prefix compare:[letterArr objectAtIndex:i]];
            
            if (result == NSOrderedAscending) { // stringOne < stringTwo
                continue;
            }
            
            if (result == NSOrderedDescending) { // stringOne > stringTwo
                continue;
            }
            
            if (result == NSOrderedSame) { // stringOne == stringTwo
                [partList addObject:song];
            }
        }
        if ([partList count] == 0) {
            [letterArr removeObjectAtIndex:i];
            continue;
        }
        for (int j = 0; j < [partList count]; j++) {
            [tmpList removeObject:[partList objectAtIndex:j]];
        }
        [songList insertObject:partList atIndex:0];
    }
    if ([tmpList count] > 0)
        [songList addObject:tmpList];
    else {
        [tmpList removeLastObject];
        [letterArr removeObject:@"#"];
    }
    
    [songTblView reloadData];
    [waitPopup stopAnimating];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [songList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [letterArr objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([songList count] <= section)
        return 0;
    NSMutableArray *partList = [songList objectAtIndex:section];
    return [partList count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 30)];
    tempLabel.backgroundColor=[UIColor groupTableViewBackgroundColor];
    tempLabel.textColor = [UIColor colorWithRed:139.0f/255.0f green:56.0f/255.0f blue:160.f/255.0f alpha:1.0f];
    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    tempLabel.text = [letterArr objectAtIndex:section];
    return tempLabel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicAddViewCell * cell = nil;
    
    NSString *cellid = @"musicAddViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"MusicAddViewCell" bundle:nil] forCellReuseIdentifier:cellid];
        cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    }

    NSMutableArray *partList = [songList objectAtIndex:indexPath.section];
    MPMediaItem *song = [partList objectAtIndex:indexPath.row];
    
    cell.titleView.text = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *artist = [song valueForProperty: MPMediaItemPropertyArtist];
    if (artist == nil) artist = @"";
    NSString *album = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
    if (album == nil) album = @"";
    
    if (![artist isEqualToString:@""]) {
        if ([album isEqualToString:@""])
            cell.infoView.text = artist;
        else
            cell.infoView.text = [NSString stringWithFormat:@"%@ - %@", artist, album];
    } else {
        cell.infoView.text = album;
    }    
    
    MPMediaItemArtwork *itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artworkUIImage = [itemArtwork imageWithSize:CGSizeMake(50, 50)];
    if (artworkUIImage != nil)
    cell.thumbView.image = artworkUIImage;
    
    cell.tag = 0;
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (NSIndexPath *path in checkedIndexPaths)
    {
        if ([path isEqual:indexPath]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.tag = 1;
        }
        // no need of else part
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *partList = [songList objectAtIndex:indexPath.section];
    MPMediaItem *song = [partList objectAtIndex:indexPath.row];
    if ([[song valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Please download music to upload." message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:TRUE completion:nil];
        return;
    }
    MusicAddViewCell *cell = (MusicAddViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag != 1) {
        cell.tag = 1;
        [checkedIndexPaths addObject:indexPath];
    } else {
        cell.tag = 0;
        [checkedIndexPaths removeObject:indexPath];
    }
    [songTblView reloadData];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return letterArr;
}

- (IBAction)saveAction:(id)sender {
//    if ([checkedIndexPaths count] == 0)
//        return;
//    [self uploadMusic:0];
//    [waitPopup startAnimating];
    for (int i = 0; i < [checkedIndexPaths count]; i++) {
        NSIndexPath *indexPath = [checkedIndexPaths objectAtIndex:i];
        NSMutableArray *partList = [songList objectAtIndex:indexPath.section];
        MPMediaItem *song = [partList objectAtIndex:indexPath.row];
        [[GlobalVars sharedInstance].songList addObject:song];
    }
    [self endAdding:true];
}

- (void)uploadMusic:(NSInteger)index {
    if (index >= [checkedIndexPaths count]) {
        [self endAdding:TRUE];
        return;
    }
    
    NSIndexPath *indexPath = [checkedIndexPaths objectAtIndex:index];
    NSMutableArray *partList = [songList objectAtIndex:indexPath.section];
    MPMediaItem *song = [partList objectAtIndex:indexPath.row];
    NSString *title = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *type = [song valueForKey:MPMediaItemPropertyMediaType];
    NSString *artist = [song valueForProperty: MPMediaItemPropertyArtist];
    if (artist == nil) artist = @"";
    NSString *album = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
    if (album == nil) album = @"";
    MPMediaItemArtwork *itemArtwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *artworkUIImage = [itemArtwork imageWithSize:CGSizeMake(50, 50)];
    float duration = 0;
    
    //convert MPMediaItem to AVURLAsset.
    AVURLAsset *sset = [AVURLAsset assetWithURL:[song valueForProperty:MPMediaItemPropertyAssetURL]];
    
    duration = CMTimeGetSeconds(sset.duration);
    
    //init export, here you must set "presentName" argument to "AVAssetExportPresetPassthrough". If not, you will can't export mp3 correct.
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:sset presetName:AVAssetExportPresetPassthrough];
    
    //export to mov format.
    export.outputFileType = @"com.apple.quicktime-movie";
    
    export.shouldOptimizeForNetworkUse = YES;
    
    NSString *extension = @"mov";
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.%@", title, extension];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (fileExists)    //Does file exist?
    {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])   //Delete it
        {
            [self endAdding:FALSE];
            return;
        }
    }
    

    NSURL *outputURL = [NSURL fileURLWithPath:path];
    export.outputURL = outputURL;
    [export exportAsynchronouslyWithCompletionHandler:^{
        
        if (export.status == AVAssetExportSessionStatusCompleted)
        {
            //then rename mov format to the original format.
            NSData *data = [NSData dataWithContentsOfFile: path];
            
            // Upload Song to Server
            NSString *fileName = title;
            if ([[title pathExtension] isEqualToString:@""]) {
                fileName = [NSString stringWithFormat:@"%@.%@", fileName, type];
            }
            NSString *newTitle = [[title lastPathComponent] stringByDeletingPathExtension];
            
            [uploadTask sendRequest:data MimeType:@"audio/mpeg3" FileName:fileName Response:^(int code, NSDictionary *result) {
                if (code == ERR_OK) {
                    NSString *songPath = [result objectForKey:@"file_path"];
                    
                    if (songPath == nil) {
                        [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
                        [self endAdding:FALSE];
                        return;
                    }
                    
                    if (artworkUIImage == nil) {
                        [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:@"" Path:songPath Index:index];
                        return;
                    } else {
                        NSData *imageData = UIImageJPEGRepresentation(artworkUIImage, 0.2);
                        [uploadTask sendRequest:imageData MimeType:@"image/png" FileName:@"thumb.png" Response:^(int code, NSDictionary *result) {
                            if (code == ERR_OK) {
                                NSString *imagePath = [result objectForKey:@"file_path"];
                                [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:imagePath Path:songPath Index:index];
                                return;
                            } else {
                                [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:@"" Path:songPath Index:index];
                                return;
                            }
                        } Progress:^(CGFloat value) {
                            
                        }];
                        return;
                    }
                } else {
                    [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
                    [self endAdding:FALSE];
                    return;
                }
                
            } Progress:^(CGFloat value) {
                
            }];

        }
        else
        {
            [self endAdding:FALSE];
            NSLog(@"%@",export.error);
        }
        
    }];
    
}


- (void)saveMusic:(NSString *)title Album:(NSString *)album Artist:(NSString *)artist Duration:(float)duration Thumb:(NSString *)thumb Path:(NSString *)path Index:(NSInteger)index {
    [musicTask sendRequest:title Album:album Artist:artist Duration:duration Thumb:(NSString *)thumb Path:path Response:^(int code, NSDictionary *result){
        if (code == ERR_OK) {
            [self uploadMusic:index + 1];
            return;
        } else {
            [self endAdding:FALSE];
            return;
        }
    }];
}

- (void)endAdding:(Boolean)success {
    [waitPopup stopAnimating];
    if (!success) {
        [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
        return;
    }
    [self.navigationController popToRootViewControllerAnimated:TRUE];
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
