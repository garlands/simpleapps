//
//  AlbumCell.m
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UILongPressGestureRecognizer *recognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    [self.contentView addGestureRecognizer:recognizer];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:
         @selector(albumCell:longPressStateChanged:atLocation:)]) {
        
        CGPoint location = [recognizer locationInView:recognizer.view];
        
        [self.delegate albumCell:self
            longPressStateChanged:recognizer.state
                       atLocation:location];
    }
}
@end
