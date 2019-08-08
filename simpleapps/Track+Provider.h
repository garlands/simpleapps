//
//  Track+Provider.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "Track.h"

@interface Track (Provider)

+ (NSArray *)musicLibraryTracks_album:(NSString*)albumTitle;

@end
