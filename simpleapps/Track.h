//
//  Track.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface Track : NSObject

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSURL *audioFileURL;
@property (nonatomic, strong) MPMediaItemArtwork *artwork;

@end
