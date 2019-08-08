//
//  Album+Provider.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "Album.h"

@interface Album (Provider)

//+ (NSArray *)remoteTracks;
+ (NSArray *)musicLibraryAlbums;

@end
