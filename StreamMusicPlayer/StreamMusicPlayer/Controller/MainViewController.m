//
//  ViewController.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "MainViewController.h"
#import "MusicPlayViewCell.h"
#import "MusicListTask.h"
#import "SaveVoteTask.h"
#import "VoteListTask.h"
#import "GlobalVars.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
#import "UploadFileTask.h"
#import "UploadMusicTask.h"
#import "SideMenu.h"

#define URL @"http://35.166.217.110:8000/listen"
//#define URL @"http://192.168.1.124:8000/listen"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noMusicView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (weak, nonatomic) IBOutlet UITableView *songListView;
@end

@implementation MainViewController {
    MusicListTask *listTask;
    SaveVoteTask *saveVoteTask;
    VoteListTask *voteListTask;
    UploadFileTask *uploadTask;
    UploadMusicTask *musicTask;
    
    NSMutableArray *songList;
    UIActivityIndicatorView *waitPopup;
    
    Boolean isMute;
    NSInteger delay;
    
    float progress;
    float prevTime;
    float currentTime;
    float oldTime;
    int pauseIndex;
    
    NSTimer *refreshTimer;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    
    SideMenu *menuView;
    UITapGestureRecognizer *tapRecognizer;
}

@synthesize songListView;
@synthesize noMusicView;
@synthesize addBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    songList = [[NSMutableArray alloc] init];
    listTask = [[MusicListTask alloc] init];
    saveVoteTask = [[SaveVoteTask alloc] init];
    voteListTask = [[VoteListTask alloc] init];
    
    uploadTask = [[UploadFileTask alloc] init];
    musicTask = [[UploadMusicTask alloc] init];
    
    waitPopup = [[GlobalVars sharedInstance] showWaitingDialog:self.view];
    
    [addBtn setImage:[[UIImage imageNamed:@"Add_Icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkUpload) userInfo:nil repeats:YES];
    
    noMusicView.hidden = TRUE;
    
    
    progress = 0;
    
    [songList removeAllObjects];
    [songListView reloadData];
    
    [waitPopup startAnimating];
    
    [self initMapView];
    
    menuView = (SideMenu *)[[[NSBundle mainBundle] loadNibNamed:@"SideMenuView" owner:self options:nil] objectAtIndex:0];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(muteClicked:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [nc.navigationBar setBarTintColor:[UIColor colorWithRed:135.0f/255.0f green:49.0f/255.0f blue:158.0f/255.0f alpha:1.0f]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:135.0f/255.0f green:49.0f/255.0f blue:158.0f/255.0f alpha:1.0f]];
    self.navigationController.navigationBar.translucent = FALSE;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:182.0f/255.0f green:129.0f/255.0f blue:197.0f/255.0f alpha:1.0f];
    
    [self refresh];
        
    // Refresh Start
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    
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
    
    [self checkUpload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [waitPopup stopAnimating];
    
    // Refresh Stop
    [refreshTimer invalidate];
    [menuView removeFromSuperview];
}

- (void)onHomeClick {
    [menuView hideView];
}
- (void)onLikeClick {
    [self performSegueWithIdentifier:@"showVoteList" sender:self];
}

- (void)refresh {
    if ([songList count] == 0) {
        oldTime = prevTime = currentTime = 0;
        pauseIndex = progress = 0;
    }
    [listTask sendRequest:[GlobalVars sharedInstance].userId Response:^(int code ,NSMutableArray *result){
        
        if (code == ERR_OK) {
            songList = [[NSMutableArray alloc] initWithArray:result];
            if ([songList count] == 0) {
                [waitPopup stopAnimating];
                noMusicView.hidden = FALSE;
            } else {
                noMusicView.hidden = TRUE;
                [self playMusic];
            }
            [songListView reloadData];
        } else {
            [waitPopup stopAnimating];
            [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
        }
    }];
}
- (IBAction)voteListAction:(id)sender {
    [menuView showView:self.view.bounds.size.width / 4 * 3];
    
//    UIAlertController * alert =   [UIAlertController
//                                   alertControllerWithTitle:nil
//                                   message:nil
//                                   preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    UIAlertAction* voteListAction = [UIAlertAction
//                                  actionWithTitle:@"Songs you’ve liked"
//                                  style:UIAlertActionStyleDefault
//                                  handler:^(UIAlertAction * action) {
//                                      //Do some thing here
//                                      [alert dismissViewControllerAnimated:YES completion:nil];
//                                      [self performSegueWithIdentifier:@"showVoteList" sender:self];
//                                      
//                                  }];
//    
//    UIAlertAction* logoutAction = [UIAlertAction
//                                  actionWithTitle:@"Log out"
//                                  style:UIAlertActionStyleDefault
//                                  handler:^(UIAlertAction * action) {
//                                      //Do some thing here
//                                      [self performSegueWithIdentifier:@"logOut" sender:self];
//                                      [alert dismissViewControllerAnimated:YES completion:nil];
//                                  }];
//    UIAlertAction* cancel = [UIAlertAction
//                             actionWithTitle:@"Cancel"
//                             style:UIAlertActionStyleDefault
//                             handler:^(UIAlertAction * action) {
//                                 [alert dismissViewControllerAnimated:YES completion:nil];
//                             }];
//    
//    [alert addAction:voteListAction];
//    [alert addAction:logoutAction];
//    [alert addAction:cancel];
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        // iPad 인 경우 처리
//        UIPopoverPresentationController *alertPopoverPresentationController = alert.popoverPresentationController;
//        UIButton *imagePickerButton = (UIButton*)sender;
//        alertPopoverPresentationController.sourceRect = imagePickerButton.frame;
//        alertPopoverPresentationController.sourceView = self.view;
//        
//        [self showDetailViewController:alert sender:sender];
//    } else {
//        [self presentViewController:alert animated:YES completion:nil];
//    }
    
}

- (IBAction)addMusicAction:(id)sender {
    [self performSegueWithIdentifier:@"showAddMusic" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [songList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicPlayViewCell * cell = nil;
    
    NSString *cellIdentifier = @"musicPlayViewCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"MusicPlayViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
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
    
    cell.muteView.hidden = TRUE;
    [cell.sliderView setValue:0];
    cell.sliderView.userInteractionEnabled = FALSE;
    cell.cityView.text = [song objectForKey:@"city"];
    if (indexPath.row == 0) {
        cell.muteView.hidden = FALSE;
        [cell.sliderView setValue:progress];
        if (isMute)
            cell.muteView.image = [UIImage imageNamed:@"Mute_Enable.png"];
        else
            cell.muteView.image = [UIImage imageNamed:@"Mute_Disable.png"];
    }
    
    if (indexPath.row == 0) {
        [cell.upBtn setImage:[UIImage imageNamed:@"Up_Arrow.png"] forState:UIControlStateNormal];
        [cell.downBtn setImage:[UIImage imageNamed:@"Down_Arrow.png"] forState:UIControlStateNormal];
    } else {
//        [cell.upBtn setImage:[UIImage imageNamed:@"Next_Up_Arrow.png"] forState:UIControlStateNormal];
//        [cell.downBtn setImage:[UIImage imageNamed:@"Next_Down_Arrow.png"] forState:UIControlStateNormal];
        cell.upBtn.hidden = TRUE;
        cell.downBtn.hidden = TRUE;
    }
    cell.thumbView.tag = indexPath.row;
    cell.upBtn.tag = indexPath.row;
    cell.downBtn.tag = indexPath.row;
    
    [cell.muteView removeGestureRecognizer:tapRecognizer];
    if (cell.muteView.hidden == FALSE)
        [cell.muteView addGestureRecognizer:tapRecognizer];
    
    [cell.upBtn addTarget:self action:@selector(upClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.downBtn addTarget:self action:@selector(downClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (indexPath.row == 0)
        cell.voteView.hidden = FALSE;
    else
        cell.voteView.hidden = TRUE;
    
    if ([song objectForKey:@"vote_value"] != nil && ![[song objectForKey:@"vote_value"] isEqual:[NSNull null]]) {
        NSInteger voteValue = [[song objectForKey:@"vote_value"] integerValue];
        if (voteValue > 0)
            [cell.voteView setText:[NSString stringWithFormat:@"+%ld", voteValue]];
        else
            [cell.voteView setText:[NSString stringWithFormat:@"%ld", voteValue]];
        
    } else {
        [cell.voteView setText:@"0"];
    }
    
    return cell;
}
- (void)muteClicked:(UIImageView*)sender
{
//    if (sender.tag == 0) {
        isMute = !isMute;
        [self setMute:isMute];
//    }
}

- (void)upClicked:(UIButton*)sender
{
    if (sender.tag != 0)
        return;
    [self voteMusic:sender.tag Value:1];
}
- (void)downClicked:(UIButton*)sender
{
    if (sender.tag != 0)
        return;
    [self voteMusic:sender.tag Value:-1];
}

- (void)voteMusic:(NSInteger)index Value:(NSInteger)value {
    NSMutableDictionary *song = [[NSMutableDictionary alloc] initWithDictionary:[songList objectAtIndex:index]];
    
    Boolean bEnableVote = TRUE;
    if ([song objectForKey:@"my_vote"] != nil && ![[song objectForKey:@"my_vote"] isEqual:[NSNull null]]) {
        if ([[song objectForKey:@"my_vote"] integerValue] > 0 && value > 0)
            bEnableVote = FALSE;
        if ([[song objectForKey:@"my_vote"] integerValue] < 0 && value < 0)
            bEnableVote = FALSE;
    }
    if (bEnableVote) {
        [waitPopup startAnimating];
        [saveVoteTask sendRequest:[GlobalVars sharedInstance].userId MusicId:[song objectForKey:@"music_id"] VoteValue:value Response:^(int code, NSDictionary * result){
            if (code == ERR_OK) {
                NSInteger voteValue = 0;
                if ([song objectForKey:@"vote_value"] != nil && ![[song objectForKey:@"vote_value"] isEqual:[NSNull null]])
                    voteValue = [[song objectForKey:@"vote_value"] integerValue];
                [song setValue:[NSNumber numberWithInteger:(voteValue + value)] forKey:@"vote_value"];
                NSInteger myVote;
                if ([[song objectForKey:@"my_vote"] isEqual:[NSNull null]])
                    myVote = value;
                else
                    myVote = [[song objectForKey:@"my_vote"] integerValue] + value;
                [song setValue:[NSNumber numberWithInteger:myVote] forKey:@"my_vote"];
                
                [songList replaceObjectAtIndex:index withObject:song];
                [songListView reloadData];
                
                if ([[result objectForKey:@"restart"] boolValue]) {
                    [[GlobalVars sharedInstance].songPlayer pause];
                    [GlobalVars sharedInstance].songPlayer = nil;
                }
                if ([[result objectForKey:@"refresh"] boolValue]) {
                    [self refresh];
                }
            } else {
                [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
            }
            [waitPopup stopAnimating];
        }];
    } else {
        [self presentViewController:[GlobalVars commonAlert:@"You have already voted this music." message:@""] animated:TRUE completion:nil];
        return;
    }
}

- (void)playMusic {
    if ([GlobalVars sharedInstance].isPlaying) {
        [waitPopup stopAnimating];
        return;
    }
    
    if ([GlobalVars sharedInstance].playerItem != nil) {
        [[GlobalVars sharedInstance].playerItem removeObserver:self forKeyPath:@"status"];
        [[GlobalVars sharedInstance].playerItem removeObserver:self forKeyPath:@"timedMetadata"];
    }
    
    isMute = false;
    
    [GlobalVars sharedInstance].playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:URL]];
    [[GlobalVars sharedInstance].playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];
    [[GlobalVars sharedInstance].playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [GlobalVars sharedInstance].songPlayer = [AVPlayer playerWithPlayerItem:[GlobalVars sharedInstance].playerItem];
    [[GlobalVars sharedInstance].songPlayer play];
    
    oldTime = prevTime = currentTime = progress = pauseIndex = 0;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"%@", keyPath);
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        for (AVMetadataItem* metadata in [GlobalVars sharedInstance].playerItem.timedMetadata)
        {
            NSLog(@"\nkey: %@\nkeySpace: %@\ncommonKey: %@\nvalue: %@", [metadata.key description], metadata.keySpace, metadata.commonKey, metadata.stringValue);
            [self nextSognPlay:[metadata.key description] Value:metadata.stringValue];
        }
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([[GlobalVars sharedInstance].playerItem status] == AVPlayerStatusFailed) {
            [GlobalVars sharedInstance].isPlaying = false;
            NSLog(@"AVPlayer Failed");
            [waitPopup stopAnimating];
            [self refresh];
        } else if ([GlobalVars sharedInstance].songPlayer.status == AVPlayerStatusReadyToPlay) {
//            [self setMute:FALSE];
            [GlobalVars sharedInstance].isPlaying = true;
            NSLog(@"AVPlayer Play");
        } else if ([GlobalVars sharedInstance].songPlayer.status == AVPlayerItemStatusUnknown) {
            [GlobalVars sharedInstance].isPlaying = false;
            NSLog(@"AVPlayer Unknown");
            [waitPopup stopAnimating];
        }
    }
}

- (void)nextSognPlay:(NSString *)key Value:(NSString *)value {
    
    int playIndex = -1;
    prevTime = currentTime;
    progress = 0;
    for (int i = 0; i < [songList count]; i ++) {
        NSDictionary *song = [songList objectAtIndex:i];
        if ([[song objectForKey:@"title"] isEqualToString:value]) {
            playIndex = i;
            NSLog(@"%d", playIndex);
            break;
        }
    }
    for (int i = playIndex - 1; i >= 0; i--) {
        [songList removeObjectAtIndex:i];
    }
    [waitPopup stopAnimating];
    [songListView reloadData];
}

- (void)setMute:(Boolean)mute {
    [GlobalVars sharedInstance].songPlayer.muted = mute;
    [songListView reloadData];
}

- (void)stopPlaying {
    [[GlobalVars sharedInstance].songPlayer pause];
    [[GlobalVars sharedInstance].songPlayer removeObserver:self forKeyPath:@"status"];
    [GlobalVars sharedInstance].songPlayer = nil;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //  code here to play next sound file
}

- (void)checkUpload {
    if ([[GlobalVars sharedInstance].songList count] > 0) {
        if ([GlobalVars sharedInstance].uploadState == 0) {
            [GlobalVars sharedInstance].uploadState = 1;
            [self uploadMusic];
        }
    } else {
        if ([GlobalVars sharedInstance].uploadState == 1)
            [GlobalVars sharedInstance].uploadState = 0;
    }
}

- (void)uploadMusic{
    if ([[GlobalVars sharedInstance].songList count] == 0) {
        [GlobalVars sharedInstance].uploadState = 0;
        return;
    }
    
    MPMediaItem *song = [[GlobalVars sharedInstance].songList objectAtIndex:0];
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
                    
                    NSString *thumbName = [NSString stringWithFormat:@"%@.png", title];
                    thumbName = [thumbName stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSString *songPath = [result objectForKey:@"file_path"];
                    
                    if (songPath == nil) {
                        [self presentViewController:[GlobalVars networkErrAlert] animated:TRUE completion:nil];
                        [self endAdding:FALSE];
                        return;
                    }
                    
                    if (artworkUIImage == nil) {
                        [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:@"" Path:songPath];
                        return;
                    } else {
                        NSData *imageData = UIImageJPEGRepresentation(artworkUIImage, 0.2);
                        [uploadTask sendRequest:imageData MimeType:@"image/png" FileName:thumbName Response:^(int code, NSDictionary *result) {
                            if (code == ERR_OK) {
                                NSString *imagePath = [result objectForKey:@"file_path"];
                                [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:imagePath Path:songPath];
                                return;
                            } else {
                                [self saveMusic:newTitle Album:album Artist:artist Duration:duration Thumb:@"" Path:songPath];
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


- (void)saveMusic:(NSString *)title Album:(NSString *)album Artist:(NSString *)artist Duration:(float)duration Thumb:(NSString *)thumb Path:(NSString *)path {
    [musicTask sendRequest:title Album:album Artist:artist Duration:duration Thumb:(NSString *)thumb Path:path Response:^(int code, NSDictionary *result){
        if (code == ERR_OK) {
            [[GlobalVars sharedInstance].songList removeObjectAtIndex:0];
            [self refresh];
            [self uploadMusic];
            return;
        } else {
            [self endAdding:FALSE];
            return;
        }
    }];
}

- (void)endAdding:(Boolean)success {
    [[GlobalVars sharedInstance].songList removeAllObjects];
}


- (void)updateProgress {
    if (![GlobalVars sharedInstance].isPlaying || [songList count] == 0)
        return;
    
    currentTime = CMTimeGetSeconds([GlobalVars sharedInstance].playerItem.currentTime);
    if (currentTime == oldTime) {
        pauseIndex ++;
        if (pauseIndex > 3) {
            [GlobalVars sharedInstance].isPlaying = false;
            [self refresh];
        }
        return;
    }
    oldTime = currentTime;
    pauseIndex = 0;
    
    float time = currentTime - prevTime;
    NSDictionary *song = [songList firstObject];
    float duration = [[song objectForKey:@"duration"] floatValue];
    
    progress = time  * 100 / duration;
    
    MusicPlayViewCell *cell = (MusicPlayViewCell *)[songListView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ( (int)cell.sliderView.value != progress) {
        [songListView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showVoteList"]) {
    }
    if ([segue.identifier isEqualToString:@"logOut"]) {
        [[GlobalVars sharedInstance].songPlayer pause];
        GlobalVars *global = [GlobalVars sharedInstance];
        global.sessionId = @"";
        global.userId = @"";
        global.email = @"";
        global.password = @"";
        global.facebookId = @"";
    }
}


- (void)initMapView {
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter = 50.0f;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [GlobalVars sharedInstance].latitude = newLocation.coordinate.latitude;
    [GlobalVars sharedInstance].longitude = newLocation.coordinate.longitude;
    
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks lastObject];
            [GlobalVars sharedInstance].posArea = @{@"city" : placemark.locality};
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

@end
