//
//  MusicAddViewCell.h
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicAddViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@end
