//
//  AlbumCell.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumCellDelegate;

@interface AlbumCell: UICollectionViewCell
@property (nonatomic, weak) id <AlbumCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@protocol AlbumCellDelegate <NSObject>
@optional
- (void)albumCell:(AlbumCell *)cell
longPressStateChanged:(UIGestureRecognizerState)state
        atLocation:(CGPoint)location;
@end
