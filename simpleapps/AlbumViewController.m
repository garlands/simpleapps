//
//  AlbumViewController.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "AlbumViewController.h"
#import "Track.h"
#import "Album.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioManager.h"
#import "AppDelegate.h"



@interface AlbumViewController ()
{

    __weak IBOutlet UIImageView *_artworkImage;

    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_artistLabel;
    
    __weak IBOutlet UITableView *_musicTableView;
@private
    UILabel *_statusLabel;
    UILabel *_miscLabel;
    
    UIButton *_buttonPlayPause;
    UIButton *_buttonStop;
    
    UILabel *_volumeLabel;
    UISlider *_volumeSlider;
    AudioManager *avmgr;
    NSTimer *_timer;
    NSTimer *_fwdred_timer;
    NSTimer *_analize_timer;
    NSTimer *_spindle_timer;
    
    
    AVAudioPlayer *audioPlayer;
    BOOL spindle_active;
    BOOL _restore_mode;
    int _album_index;
    int _update_index;
    int _album_kind;
    NSString *_album_title;
}
@property (nonatomic) NSMutableArray *items;
@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _update_index = -1;
//    self.view.backgroundColor = UIColor.blackColor;
    _musicTableView.tableFooterView = [UIView new];

    avmgr = [AudioManager sharedInstance];
    
    _album_index = [avmgr getCurrentAlumIndex:_restore_mode];

    [avmgr setupAlbum:NO download:NO];
    BOOL temp = YES;
    if( _restore_mode == YES )
        temp = NO;
    _album_title = [avmgr getCurrentAlbumTitle:temp];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeMusic:) name:kChangeMusicNotification object: nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)receiveRotateScreen:(NSNotification*)notification
{
    [_musicTableView setNeedsDisplay];
    [_musicTableView reloadData];
}

-(void) enterBackground
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) receiveChangeMusic:(NSNotification *)notification
{
    int current = [avmgr getCurrentAlumIndex:YES];
    if( current == _album_index )
    {
        _update_index = [avmgr getCurrentTrackIndex:NO];

        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_update_index inSection:0];
        NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
        [_musicTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        [_musicTableView setNeedsDisplay];
        [_musicTableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_update_index inSection:0];
            [_musicTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        });
    }
}

- (IBAction)_touchUpUnderButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [avmgr countTracks:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    int total_sec = [avmgr getSelectDuringTime:(int)indexPath.row restoremode:NO];
    UILabel *number = [cell viewWithTag:3];
    number.text = [NSString stringWithFormat:@"%d",(int)(indexPath.row + 1)];
    
    UILabel *title = [cell viewWithTag:1];
    title.text = [avmgr getSelectTitle:(int)indexPath.row restoremode:NO];
    
    if( _update_index == indexPath.row )
        title.textColor = UIColor.greenColor;
    else
        title.textColor = UIColor.whiteColor;
    
    UILabel *during = [cell viewWithTag:2];
    int min = total_sec / 60;
    int sec = total_sec % 60;
    if( sec < 10 )
        during.text = [NSString stringWithFormat:@"%d:0%d",min,sec];
    else
        during.text = [NSString stringWithFormat:@"%d:%d",min,sec];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [avmgr terminateAudioPlayer];
//    [avmgr selectMusic:(int)indexPath.row];
    [avmgr startSelectMusic:(int)indexPath.row];
}


@end
