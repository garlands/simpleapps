//
//  MiniPlayerTabBar.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "MiniPlayerTabBar.h"
#import "AppDelegate.h"
#import "AudioManager.h"
#import "MiniPlayerView.h"

@interface MiniPlayerTabBar () {
    MiniPlayerView *_miniPlayerView;
    BOOL _portrait;
    BOOL init;
}
@end

@implementation MiniPlayerTabBar
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil ){
        _miniPlayerView = NULL;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if( init == NO )
    {
#if 0 //use delegate
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeMusic:) name:kChangeMusicNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChangeAudioState:) name:kChangeAudioStateNotification object: nil];
#endif
    }
    init = YES;
    
    float save_bottom = 0;
    if (@available(iOS 11.0, *)) {
        save_bottom = (int)self.safeAreaInsets.bottom;
    }
    self.backgroundColor = UIColor.darkGrayColor;
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : UIColor.whiteColor };
    [[UITabBarItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSDictionary *attributesSelected = @{ NSForegroundColorAttributeName : UIColor.whiteColor };
    [[UITabBarItem appearance] setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];

    if( _miniPlayerView == NULL )
    {
        [self createMiniPlayer];
    }else{
        for (UIView *v in self.subviews) {
            [v removeFromSuperview];
        }
        
        _miniPlayerView = NULL;
        [self createMiniPlayer];
        
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize ret_size = [super sizeThatFits:size];
    ret_size.height = ret_size.width / 4;
    return ret_size;
}

#pragma mark - Receive Notification
#if 0 //use delegate
-(void)receiveChangeMusic:(NSNotification *)notification
{
    if( _miniPlayerView != NULL )
        [_miniPlayerView receiveChangeMusic];
}

-(void)receiveChangeAudioState:(NSNotification *)notification
{
    int state = [[notification.userInfo objectForKey:@"state"] intValue];
    if( _miniPlayerView != NULL )
        [_miniPlayerView receiveChangeAudioState:state];
}
#endif

-(void) createMiniPlayer
{
    if( _miniPlayerView == NULL )
    {
        float save_bottom = 0;
        if (@available(iOS 11.0, *)) {
            save_bottom = (int)self.safeAreaInsets.bottom;
        }
        _miniPlayerView = [[MiniPlayerView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height - save_bottom)];
        _miniPlayerView.backgroundColor = UIColor.darkGrayColor;
        [self addSubview:_miniPlayerView];
    }
}
@end
