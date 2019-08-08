//
//  AlbumViewController.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewController : UIViewController
@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic, copy) NSArray *albums;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL restore_mode;
@property (nonatomic) int album_kind;
-(void) enterBackground;
@end
