//
//  AlbumCollectionViewController.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewController: UICollectionViewController
@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic, copy) NSArray *albums;
@property (nonatomic) NSNumber *album_kind;
@end
