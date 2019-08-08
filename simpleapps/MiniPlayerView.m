//
//  MiniPlayerView.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "MiniPlayerView.h"
#import "AppDelegate.h"
#import "AudioManager.h"
#import "MiniPlayerTabBar.h"

@interface MiniPlayerView ()
{
    UIButton *_miniNextButton;
    UIButton *_miniPlayButton;
    UIImageView *_miniplayerArtworkImageView;
    UILabel *_miniplayerTitleLabel;
    UILabel *_miniplayerArtistLabel;
    AudioManager *avmgr;
}
@end

@implementation MiniPlayerView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self != NULL )
    {
        [self initMiniPlayer];
    }
    return self;
}

-(void) initMiniPlayer
{
    avmgr = [AudioManager sharedInstance];
    float artsize = self.frame.size.height * .5f;
    UIImage *artworkImage = [avmgr getCurrentTrackArtworkImage:CGSizeMake(artsize, artsize) restoremode:YES];
    if( artworkImage == NULL )
    {
        artworkImage = [UIImage imageNamed:@"logo.png"];
    }
    _miniplayerArtworkImageView = [[UIImageView alloc] initWithImage:artworkImage];
    _miniplayerArtworkImageView.clipsToBounds = YES;
    _miniplayerArtworkImageView.layer.cornerRadius = 3.0;
    _miniplayerArtworkImageView.frame = CGRectMake(self.frame.size.width * 0.02f, self.frame.size.height * 0.1f, artsize, artsize);
    [self addSubview:_miniplayerArtworkImageView];
    
    float label_font_size = self.frame.size.height * 0.2f;
    float x = _miniplayerArtworkImageView.frame.origin.x + _miniplayerArtworkImageView.frame.size.width + self.frame.size.width * 0.02f;
    float y = self.frame.size.height * 0.1f;
    float width = self.frame.size.width * .6f;
    float height = label_font_size * 1.4f;
    
    _miniplayerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _miniplayerTitleLabel.textColor = UIColor.whiteColor;
    _miniplayerTitleLabel.textAlignment = NSTextAlignmentLeft;
    _miniplayerTitleLabel.text = @"";
    _miniplayerTitleLabel.font = [UIFont systemFontOfSize:label_font_size];
    [self addSubview:_miniplayerTitleLabel];

    
    y = _miniplayerTitleLabel.frame.size.height + self.frame.size.height * 0.1f;
    _miniplayerArtistLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    _miniplayerArtistLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    _miniplayerArtistLabel.textAlignment = NSTextAlignmentLeft;
    _miniplayerArtistLabel.font = [UIFont systemFontOfSize:label_font_size];
    _miniplayerArtistLabel.text = @"";
    [self addSubview:_miniplayerArtistLabel];

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    float btn_x = self.frame.size.width;
    if( screenSize.size.width > screenSize.size.height ) //landscape
        btn_x = self.frame.size.width * 0.9f;
    
    NSString *str;
    if( [avmgr isPlaying] == YES )
        str = @"mini_pause.png";
    else
        str = @"mini_play.png";
    UIImage *miniPlay_image = [UIImage imageNamed:str];
    _miniPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(btn_x - artsize * 1.1f, self.frame.size.height * 0.1f, artsize, artsize)];
    [_miniPlayButton setBackgroundImage:miniPlay_image forState:UIControlStateNormal];
    [_miniPlayButton addTarget:self action:@selector(_touchUpMiniPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_miniPlayButton];
    
    UIImage *miniNext_image = [UIImage imageNamed:@"mini_next.png"];
    _miniNextButton = [[UIButton alloc] initWithFrame:CGRectMake(btn_x - artsize * 2.2f, self.frame.size.height * 0.1f, artsize, artsize)];
    [_miniNextButton setBackgroundImage:miniNext_image forState:UIControlStateNormal];
    [_miniNextButton addTarget:self action:@selector(_touchUpMiniNextButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_miniNextButton];
    
    [self updateLabels];
}

-(void)receiveChangeMusic
{
    [self updateLabels];
}

-(void)receiveClearMusic
{
    UIImage *artworkImage = [UIImage imageNamed:@"logo.png"];
    _miniplayerArtworkImageView.image = artworkImage;
    _miniplayerTitleLabel.text = @"";
    _miniPlayButton.enabled = NO;
    _miniNextButton.enabled = NO;
    [_miniPlayButton setBackgroundImage:[UIImage imageNamed:@"mini_play.png"] forState:UIControlStateNormal];
}

-(void) updateLabels
{
    float artsize = self.frame.size.height * .7f;
    UIImage *artworkImage = [avmgr getCurrentTrackArtworkImage:CGSizeMake(artsize, artsize) restoremode:YES];

    if( artworkImage == NULL )
    {
        artworkImage = [UIImage imageNamed:@"logo.png"];
    }
    _miniplayerArtworkImageView.image = artworkImage;
    
    NSString *title_str = [avmgr getCurrentTitleString];
    if( title_str != NULL )
        _miniplayerTitleLabel.text = title_str;
    else
        _miniplayerTitleLabel.text = @"";
    NSString *artist_str = [avmgr getCurrentArtistString];
    if( artist_str != NULL )
        _miniplayerArtistLabel.text = artist_str;
    else
        _miniplayerArtistLabel.text = @"";
}

-(void)receiveChangeAudioState:(int)state
{
    switch(state){
        case state_none:
            [self stopMusic];
            break;
        case state_stop:
            [self stopMusic];
            break;
        case state_play:
            [self updateLabels];
            [self receiveUpdateCasetteState:NO];
            [self playMusic];
            break;
        case state_terminate:
            [self stopMusic];
            break;
    }
}

-(void) receiveUpdateCasetteState:(BOOL)eject
{
    if( eject == YES )
    {
        _miniNextButton.enabled = NO;
        _miniPlayButton.enabled = NO;
    }else{
        _miniNextButton.enabled = YES;
        _miniPlayButton.enabled = YES;
    }
}


-(void)stopMusic
{
    [_miniPlayButton setBackgroundImage:[UIImage imageNamed:@"mini_play.png"] forState:UIControlStateNormal];
}

-(void)playMusic
{
    [_miniPlayButton setBackgroundImage:[UIImage imageNamed:@"mini_pause.png"] forState:UIControlStateNormal];
    
    float artsize = self.frame.size.height * .8f;
    UIImage *artworkImage = [avmgr getCurrentTrackArtworkImage:CGSizeMake(artsize, artsize) restoremode:YES];
    if( artworkImage == NULL )
    {
        artworkImage = [UIImage imageNamed:@"logo.png"];
    }
    _miniplayerArtworkImageView.image = artworkImage;
}

-(void)_touchUpMiniPlayButton:(UIButton*)button{
    if( [avmgr isPlaying] == YES )
        [avmgr pauseMusic];
    else
        [avmgr playMusic];
}

-(void)_touchUpMiniNextButton:(UIButton*)button{
    [avmgr _nextMusic];
}

@end
