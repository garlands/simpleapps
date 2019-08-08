//
//  Album+Provider.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "Album+Provider.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Album (Provider)

+ (void)load
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self musicLibraryAlbums];
  });
}


+ (NSArray *)musicLibraryAlbums
{
  static NSArray *albums = nil;
    NSMutableArray *allAlbums = [NSMutableArray array];
    MPMediaQuery *query = [MPMediaQuery albumsQuery];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    
    NSArray *albumlists = query.collections;
    for (MPMediaItemCollection *albumlist in albumlists) {
        MPMediaItem *item = [albumlist representativeItem];
        Album *album = [[Album alloc] init];
        [album setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
        [album setAlbum:[item valueForProperty:MPMediaItemPropertyAlbumTitle]];
        [album setArtwork:[item valueForProperty:MPMediaItemPropertyArtwork]];
        [allAlbums addObject:album];
    }

    albums = [allAlbums copy];
  return albums;
}

@end
