//
//  Track+Provider.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//


#import "Track+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Track (Provider)

+ (void)load
{
}

+ (NSArray *)musicLibraryTracks_album:(NSString*)albumTitle
{
    static NSArray *tracks = nil;
    NSMutableArray *allTracks = [NSMutableArray array];
    for (MPMediaItem *item in [[MPMediaQuery albumsQuery] items]) {
        if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
            continue;
        }
        if ([[item valueForProperty:MPMediaItemPropertyHasProtectedAsset] boolValue]) {
            continue;
        }
        if( [albumTitle isEqualToString:[item valueForProperty:MPMediaItemPropertyAlbumTitle]] == YES )
        {
            NSString *url_str = [item valueForProperty:MPMediaItemPropertyAssetURL];
            if( url_str != NULL )
            {
                Track *track = [[Track alloc] init];
                [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
                [track setAlbum:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
                [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
                [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
                [track setDuration:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
                [allTracks addObject:track];
            }
        }
    }
    tracks = [allTracks copy];
    
    return tracks;
}

@end
