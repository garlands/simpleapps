//
//  MiniPlayerView.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniPlayerView: UIView
- (id)initWithFrame:(CGRect)frame;
-(void)receiveChangeMusic;
-(void)receiveChangeAudioState:(int)state;
-(void) receiveUpdateCasetteState:(BOOL)eject;
-(void)receiveClearMusic;
@end
