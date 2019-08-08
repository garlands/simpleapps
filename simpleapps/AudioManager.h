//
//  AudioManager.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Track.h"
#import "Album.h"


#define kErrorMusicNotification @"kErrorMusicNotification"
#define kChangeMusicNotification @"kChangeMusicNotification"
#define kChangeAudioStateNotification @"kChangeAudioStateNotification"


@protocol AudioManagerDelegate;


typedef NS_ENUM(int, state_type) {
    state_none,
    state_stop,
    state_play,
    state_terminate,
};


typedef NS_ENUM(int, play_kind) {
    play_kind_select_play = 0,
    play_kind_prepare,
    play_kind_current_play,
};


typedef NS_ENUM(int, abortWaveImage_kind) {
    abortWaveImage_kind_none = -1,
    abortWaveImage_kind_prev,
    abortWaveImage_kind_next,
    abortWaveImage_kind_under
};


@interface AudioManager: NSObject
@property (atomic, retain)id<AudioManagerDelegate> delegate;

@property (nonatomic, copy) NSArray *tracksTemp;
@property (nonatomic, copy) NSArray *albumsTemp;
@property (nonatomic) NSInteger album_index_Temp;
@property (nonatomic) BOOL selected_music;
@property (nonatomic) BOOL now_effect;

+ (AudioManager *)sharedInstance;
- (id) init;
- (id) initWithDelegate:(id<AudioManagerDelegate>)delegate;
//- (id) init;
-(void) terminateAudioPlayer;
-(void) removeDelegate;

-(void) setupAlbum:(BOOL)restoremode download:(BOOL)download;
-(void) startSelectMusic:(int)index;
-(void) selectMusic:(int)index;
-(void) startMusic:(int)play_kind;
-(void) playMusic;
- (void) togglePlayStop;
-(void) pauseMusic;
-(void) _nextMusic;
-(void) _prevMusic;
-(BOOL) isPlaying;
-(void) configNowPlayingInfoCenter;

-(int) countTracks:(BOOL)restore_mode;
-(void) setCurrentTime:(float)value;
-(NSURL*) getCurrentSpecifyAudioURL:(int)index restoremode:(BOOL)restore_mode;
-(void) setCurrentAlbumTitle:(BOOL)temp albumtitle:(NSString*)albumtitle;
-(NSString*) getCurrentAlbumTitle:(BOOL)temp;


-(UIImage*) getAlbumArtworkImage:(CGSize)frame;
-(NSString*)getCurrentTitleString;
-(NSString*)getCurrentArtistString;

-(UIImage*) getCurrentTrackArtworkImage:(CGSize)size restoremode:(BOOL)restoremode;
-(int)getSelectDuringTime:(int)index restoremode:(BOOL)restoremode;
-(NSString*)getSelectTitle:(int)index restoremode:(BOOL)restoremode;

-(Album*)getCurrentAlbum:(BOOL)restoremode;
-(int)getCurrentAlumIndex:(BOOL)restoremode;
-(int)getCurrentTrackIndex:(BOOL)restoremode;
-(void) setCurrentTitmeCenter:(float)value;
-(void)releaseArray;
@end



@protocol AudioManagerDelegate <NSObject>
- (void) changeAudioStateAvmgr:(int)state;
- (void) errorMusicAvmgr;
- (void) updateMusicTitleAvmgr:(NSString*)title;
@end

