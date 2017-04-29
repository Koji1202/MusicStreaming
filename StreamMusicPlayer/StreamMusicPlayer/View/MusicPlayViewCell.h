//
//  MusicPlayViewCell.h
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicPlayViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *muteView;
@property (weak, nonatomic) IBOutlet UIButton *upBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UILabel *voteView;
@property (weak, nonatomic) IBOutlet UILabel *cityView;
@end
