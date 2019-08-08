//
//  AudioManager.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#define WAVE_BUFFER_SECONDS 1
#define PAI 3.14f
#define SPINDLE_TIMER 0.1f


@interface AudioManager () <AVAudioPlayerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    NSArray *_albumsTemp;
    NSUInteger _currentTrackIndex;
    MPMediaItemArtwork *_albumArtwork_Temp;
    NSString *_album_album_Temp;
    NSInteger _album_index_Temp;
    
    BOOL _selected_music;
    BOOL _now_effect;
    BOOL _prepare_music;
    BOOL _needShowClosedHelp;
    BOOL _needShowOpenHelp;
    float _total_duration;
    
@private
    AVAudioPlayer *audioPlayer;
    NSTimer *_timer;
    NSTimer *_fwdred_timer;
    NSTimer *_analize_timer;
    NSMutableArray *wave_array;
    AudioBufferList *bufferList;
    NSTimeInterval bufferTime;
    NSInteger bufferCount;
    UInt64 totalFrames;
    Float64 sampleRate;
    CGSize wavebarSize;
    dispatch_queue_t queue;
    NSMutableDictionary *controlCenter_dict;
}
@end

@implementation AudioManager
static AudioManager *sharedInstance = nil;

+ (AudioManager *)sharedInstance
{
    if ( sharedInstance == nil ){
        sharedInstance = [[AudioManager alloc] init];
    }
    
    return sharedInstance;
}


- (id)init
{
    self = [super init];
    NSLog(@"init");
    if ( self != nil ){
        _selected_music = NO;
        _prepare_music = NO;
        _albumsTemp = NULL;
    }
    return self;
}
        
- (id)initWithDelegate:(id<AudioManagerDelegate>)delegate
{
    self = [super init];
    NSLog(@"initWithDelegate");
    if ( self != nil ){
        _delegate = delegate;

        queue = dispatch_queue_create("net.jp.garlands.loadbuffer", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioSessionRouteChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        [self watchStartEarphone:YES];
    }
    return self;
}
-(void) removeDelegate
{
    _delegate = nil;
}


#pragma mark - Audio Control API
-(void) setupAlbum:(BOOL)restoremode download:(BOOL)download
{
    NSLog(@"setupAlbum");
    if( _album_index_Temp < [_albumsTemp count] ){
        Album *album = [_albumsTemp objectAtIndex:(int)_album_index_Temp];
        _albumArtwork_Temp = album.artwork;
    }
}

-(void) terminateAudioPlayer
{
    NSLog(@"terminateAudioPlayer");
    _prepare_music = NO;
    [self releaseArray];
    if ([_fwdred_timer isValid])
        [_fwdred_timer invalidate];
    if ([_analize_timer isValid])
        [_analize_timer invalidate];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state_terminate], @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeAudioStateNotification object:self userInfo:userInfo];
    [_delegate changeAudioStateAvmgr:state_terminate];

    [audioPlayer stop];
    audioPlayer.meteringEnabled = false;
    audioPlayer = nil;
}



-(void) startSelectMusic:(int)index
{
    _currentTrackIndex = index;
    [self startMusic:play_kind_select_play];
}

-(void) selectMusic:(int)index
{
    _currentTrackIndex = index;
    _selected_music = YES;
}

-(void) startMusic:(int)play_kind
{
    _selected_music = NO;
    switch(play_kind)
    {
        case play_kind_current_play:
        {
            if( _prepare_music == YES && audioPlayer != NULL )
            {
                _prepare_music = YES;
                [self playStartMusic];
            }else{
                [self prepareMusic];
                _prepare_music = YES;
                [self playStartMusic];
            }
        }
            break;
        case play_kind_prepare:
        {
            if( [self prepareMusic] == YES )
            {
                _prepare_music = YES;
            }
        }
            break;
        case play_kind_select_play:
        {
            if( [self prepareMusic] == YES )
            {
                _prepare_music = YES;
                [self playStartMusic];
            }
        }
            break;
    }
}

-(BOOL) prepareMusic
{
    BOOL ret = NO;
    
    Track *track;
    if( _currentTrackIndex < [_tracksTemp count])
        track = [_tracksTemp objectAtIndex:_currentTrackIndex];
    else
        return NO;
    
    NSLog(@"%@", track.audioFileURL);
    if( track.audioFileURL )
    {
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:track.audioFileURL
                                                             error:&error];
        if( !error )
        {
            AVAudioSession* session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            [session setActive:YES error:&error];
            if( !error )
            {
                audioPlayer.enableRate = true;
                audioPlayer.meteringEnabled = true;
                [audioPlayer prepareToPlay];
                
                [audioPlayer setDelegate:self];
                audioPlayer.numberOfLoops = 0;
                
                if( track.title )
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeMusicNotification object:self userInfo:nil];
                    
                    [_delegate updateMusicTitleAvmgr:track.title];
                    
                    [self configNowPlayingInfoCenter];
                    ret = YES;
                }
                else
                    NSLog(@"empty title");
            }
            else
                NSLog(@"%@",error);
        }
        else
            NSLog(@"%@",error);
    }else{
        NSLog(@"empty url");
    }
    return ret;
}

-(void) playStartMusic
{
    [audioPlayer play];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state_play], @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeAudioStateNotification object:self userInfo:userInfo];
    
    [_delegate changeAudioStateAvmgr:state_play];
    
    [self configNowPlayingInfoCenter];
    
    if( ![_timer isValid] ){
        NSLog(@"TIMER: active");
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    }
}


-(void) pauseMusic
{
    NSLog(@"WAVE: pauseMusic");
    [audioPlayer pause];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state_stop], @"state", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeAudioStateNotification object:self userInfo:userInfo];
    [_delegate changeAudioStateAvmgr:state_stop];
}

-(void) playMusic
{
    if( audioPlayer != NULL)
    {
        if( ![audioPlayer isPlaying] )
        {
            
            [audioPlayer play];
            if( ![_timer isValid] ){
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
            }
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:state_play], @"state", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeAudioStateNotification object:self userInfo:userInfo];
            [_delegate changeAudioStateAvmgr:state_play];
        }
    }else{
        [self startMusic:play_kind_current_play];
    }
}

- (void) togglePlayStop
{
    if( audioPlayer.isPlaying )
    {
        [self pauseMusic];
    }else{
        [self playMusic];
    }
}

-(void) _nextMusic
{
    [self nextMusic];
}

-(void) nextMusic
{
    BOOL now_play = [audioPlayer isPlaying];
    [self terminateAudioPlayer];
    
    NSUInteger count = 0;
    for( Track *track in _tracksTemp ) {
        if( track.audioFileURL != NULL )
            count = count + 1;
    }

    if (_currentTrackIndex + 1 < count) {
        _currentTrackIndex += 1;

        if( now_play == YES )
            [self startMusic:play_kind_select_play];
        else
            [self startMusic:play_kind_prepare];
    }else{
        [_delegate changeAudioStateAvmgr:state_stop];
    }
}

-(void) _prevMusic
{
    [self prevMusic];
}

-(void) prevMusic
{
    BOOL now_play = [audioPlayer isPlaying];

    if (_currentTrackIndex > 0) {
        [self terminateAudioPlayer];

        _currentTrackIndex--;
        if( now_play == YES )
            [self startMusic:play_kind_select_play];
        else
            [self startMusic:play_kind_prepare];
    }else{
        [self pauseMusic];
        if( audioPlayer != NULL )
            [audioPlayer setCurrentTime:0];
        [_delegate changeAudioStateAvmgr:state_stop];
    }
}

-(BOOL) isPlaying
{
    BOOL ret = FALSE;
    if( [audioPlayer isPlaying] )
        ret = TRUE;
    return ret;
}

-(int) countTracks:(BOOL)restore_mode
{
    int count = 0;
    count = (int)_tracksTemp.count;
    return count;
}

-(void) setCurrentTime:(float)value
{
    [audioPlayer setCurrentTime:value];
    [self setCurrentTitmeCenter:value];
}

-(NSURL*) getCurrentSpecifyAudioURL:(int)index restoremode:(BOOL)restore_mode
{
    Track *track;
    if( index < [_tracksTemp count])
        track = [_tracksTemp objectAtIndex:index];
    else{
        return NULL;
    }
    return track.audioFileURL;
}

-(void) setCurrentAlbumTitle:(BOOL)temp albumtitle:(NSString*)albumtitle
{
    _album_album_Temp = albumtitle;
}
-(NSString*) getCurrentAlbumTitle:(BOOL)temp
{
    return _album_album_Temp;
}


-(UIImage*) getAlbumArtworkImage:(CGSize)size
{
    if( _albumArtwork_Temp == NULL )
        NSLog(@" getAlbumArtworkImage is NULL");
    return [_albumArtwork_Temp imageWithSize:CGSizeMake(size.width, size.height)];
}

-(UIImage*) getCurrentTrackArtworkImage:(CGSize)size restoremode:(BOOL)restoremode
{
    if( _albumArtwork_Temp != NULL )
        return [_albumArtwork_Temp imageWithSize:CGSizeMake(size.width, size.height)];

    return NULL;
}

-(NSString*)getSelectTitle:(int)index restoremode:(BOOL)restoremode
{
    Track *track = NULL;

    if( index >= 0 && index < [_tracksTemp count] ){
        track = [_tracksTemp objectAtIndex:index];
    }else{
        NSLog(@"getSelectTitle irregal index");
    }
    if( track != NULL ){
        return track.title;
    }else{
        return NULL;
    }
}

-(NSString*)getCurrentTitleString
{
    Track *track;
    
    if( _currentTrackIndex < [_tracksTemp count]){
        track = [_tracksTemp objectAtIndex:_currentTrackIndex];
        return [track title];
    }
    return NULL;
}
-(NSString*)getCurrentArtistString;
{
    Track *track;
    if( _currentTrackIndex < [_tracksTemp count]){
        track = [_tracksTemp objectAtIndex:_currentTrackIndex];
        if( track != NULL )
            return [track artist];
    }
    return NULL;
}



-(Album*)getCurrentAlbum:(BOOL)restoremode
{
    if( [_albumsTemp count] > _album_index_Temp )
        return [_albumsTemp objectAtIndex:_album_index_Temp];
    return NULL;
}

-(int)getCurrentAlumIndex:(BOOL)restoremode
{
    return (int)_album_index_Temp;
}


-(int)getCurrentTrackIndex:(BOOL)restoremode
{
    return (int)_currentTrackIndex;
}


-(int)getSelectDuringTime:(int)index restoremode:(BOOL)restoremode
{
    int duringtime = 0;
    Track *track = NULL;
    if( [_tracksTemp count] > index )
        track = [_tracksTemp objectAtIndex:index];
    if( track != NULL ){
        duringtime = (int)[track.duration intValue];
        NSLog(@"   during tiem  %d", duringtime);
    }
    return duringtime;
}


#pragma mark - AVAudioDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {

    [audioPlayer stop];
    NSUInteger count = 0;

    for( Track *track in _tracksTemp ) {
        if( track.audioFileURL != NULL )
            count = count + 1;
    }
    
    
    if ( _currentTrackIndex + 1 < count) {
        _currentTrackIndex += 1;
        [self startMusic:play_kind_select_play];
    }else{
        [self setCurrentTime:0];
        [self pauseMusic];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    [[NSNotificationCenter defaultCenter] postNotificationName:kErrorMusicNotification object:self userInfo:nil];
    [_delegate errorMusicAvmgr];
}


#pragma mark - Timer
- (void)_timerAction:(id)timer
{
    if ([audioPlayer duration] == 0.0) {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0f], @"slider", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSliderNotification object:self userInfo:userInfo];
    }
    else {
        if( [audioPlayer duration] == 0 )
            NSLog(@"audioManager _timerAction NaN");
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:[audioPlayer currentTime] / [audioPlayer duration]], @"slider", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSliderNotification object:self userInfo:userInfo];
    }
}




#pragma mark - Controll Center

- (void) configNowPlayingInfoCenter
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    controlCenter_dict = [[NSMutableDictionary alloc] init];
    Album *album = [_albumsTemp objectAtIndex:(int)_album_index_Temp];
    
    MPMediaItemArtwork *artwork = album.artwork;
    
    Track *track;
    if( _currentTrackIndex < [_tracksTemp count])
        track = [_tracksTemp objectAtIndex:_currentTrackIndex];
    else
        return;

    [controlCenter_dict setObject:track.title forKey:MPMediaItemPropertyTitle];
    NSString *str = album.artist;
    if( str == NULL )
        str = @"";
    [controlCenter_dict setObject:str forKey:MPMediaItemPropertyArtist];
    str = album.album;
    if( str == NULL )
        str = @"";
    [controlCenter_dict setObject:str forKey:MPMediaItemPropertyAlbumTitle];
    [controlCenter_dict setObject:track.duration forKey:MPMediaItemPropertyPlaybackDuration];
    [controlCenter_dict setObject:[NSNumber numberWithFloat:1.0f] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    if( artwork != NULL )
        [controlCenter_dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    
    [playingInfoCenter setNowPlayingInfo:controlCenter_dict];
}

-(void) setCurrentTitmeCenter:(float)value
{
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    [controlCenter_dict setObject:[NSNumber numberWithFloat:value] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [playingInfoCenter setNowPlayingInfo:controlCenter_dict];
}

-(void) setRateCenter:(float)value
{
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    if( playingInfoCenter != NULL )
    {
        [controlCenter_dict setObject:[NSNumber numberWithFloat:value] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        [playingInfoCenter setNowPlayingInfo:controlCenter_dict];
    }
}

-(void)releaseArray
{
    NSLog(@"WAVE releaseArray");
    [wave_array removeAllObjects];
    //    [wave_pos1_array removeAllObjects];
    wave_array = nil;
    //    wave_pos1_array = nil;
}

#pragma mark - Earphone
- (BOOL)checkEarphone
{
    BOOL ret = false;
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]){
        NSString *portType = desc.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones] || [portType isEqualToString:AVAudioSessionPortBluetoothA2DP]){
            NSLog(@"earphone found!");
            ret = true;
        }
        return ret;
    }
    return ret;
}

- (void)audioSessionRouteChanged:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason audioSessionRouteChangeReason = [userInfo[@"AVAudioSessionRouteChangeReasonKey"] longValue];
    AVAudioSessionRouteDescription* audioSessionRouteDescription = userInfo[@"AVAudioSessionRouteChangePreviousRouteKey"];
    AVAudioSessionPortDescription* audioSessionPortDescription = audioSessionRouteDescription.outputs[0];
    
    switch (audioSessionRouteChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@" AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            [self watchStartEarphone:YES];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@" AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            if([audioSessionPortDescription.portType isEqualToString:@"Headphones"]) {
                [self watchStartEarphone:NO];
            }
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@" AVAudioSessionRouteChangeReasonOverride");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@" AVAudioSessionRouteChangeReasonCategoryChange");
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            NSLog(@" AVAudioSessionRouteChangeReasonRouteConfigurationChange");
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@" AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@" AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@" AVAudioSessionRouteChangeReasonUnknown");
            break;
        default:
            NSLog(@"audioSessionRouteChanged other");
            break;
    }
}

- (void)watchStartEarphone:(BOOL)watch
{
    NSLog(@"enter watchStartEarphone");
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    if( watch == true )
    {
        NSLog(@" watch start");
        [rcc.togglePlayPauseCommand removeTarget:self];
        [rcc.playCommand removeTarget:self];
        [rcc.pauseCommand removeTarget:self];
        [rcc.nextTrackCommand removeTarget:self];
        [rcc.previousTrackCommand removeTarget:self];
        [rcc.changePlaybackPositionCommand removeTarget:self];

        [rcc.togglePlayPauseCommand addTarget:self action:@selector(onEarphoneToggle:)];
        [rcc.playCommand addTarget:self action:@selector(onEarphonePlay:)];
        [rcc.pauseCommand addTarget:self action:@selector(onEarphonePause:)];
        [rcc.nextTrackCommand addTarget:self action:@selector(onEarphoneNextTrack:)];
        [rcc.previousTrackCommand addTarget:self action:@selector(onEarphonePrevTrack:)];
        [rcc.changePlaybackPositionCommand addTarget:self action:@selector(onChangePlaybackPositionCommand:)];
    }else{
        NSLog(@" watch end");
        [rcc.togglePlayPauseCommand removeTarget:self];
        [rcc.playCommand removeTarget:self];
        [rcc.pauseCommand removeTarget:self];
        [rcc.seekBackwardCommand removeTarget:self];
        [rcc.seekForwardCommand removeTarget:self];
        [rcc.seekForwardCommand removeTarget:self];
    }
}

- (void) onEarphoneToggle:(MPRemoteCommandEvent*)event
{
    if( [self countTracks:YES] > 0 )
        [self togglePlayStop];
}

- (void) onEarphonePlay:(MPRemoteCommandEvent*)event
{
    if( [self countTracks:YES] > 0 )
        [self playMusic];
}

- (void) onEarphonePause:(MPRemoteCommandEvent*)event
{
    if( [self countTracks:YES] > 0 )
        [self pauseMusic];
}

-(void) onSeekBackward:(MPRemoteCommandEvent*)event
{
    NSLog(@"enter MPRemoteCommandEvent");
}


- (void) onSkipForward:(MPRemoteCommandEvent*)event
{
    NSLog(@"enter onSkipForward");
}

- (void) onSkipBackward:(MPRemoteCommandEvent*)event
{
    NSLog(@"enter onSkipBackward");
}

- (void) onChangePlaybackRateCommand:(MPRemoteCommandEvent*)event
{
    NSLog(@"enter onChangePlaybackRateCommand");
}

- (MPRemoteCommandHandlerStatus) onChangePlaybackPositionCommand:(MPChangePlaybackPositionCommandEvent*)event
{
    NSLog(@"enter onChangePlaybackPositionCommand %f", event.positionTime);
    if( [self countTracks:YES] > 0 ){
        [self setCurrentTime:event.positionTime];
        return MPRemoteCommandHandlerStatusSuccess;
    }
    return MPRemoteCommandHandlerStatusNoSuchContent;
}




- (void) onSeekForward:(MPRemoteCommandEvent*)event
{
    NSLog(@"enter onSeekForward");
    
}

- (void) onEarphoneNextTrack:(MPRemoteCommandEvent*)event
{
    if( [self countTracks:YES] > 0 )
        [self nextMusic];
}

- (void) onEarphonePrevTrack:(MPRemoteCommandEvent*)event
{
    if( [self countTracks:YES] > 0 )
        [self prevMusic];
}

@end
