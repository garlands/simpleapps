//
//  MiniPlayerTabBar.h
//  simpleapps
//
//  Created by Masahiro Tamamura on 2019/08/07.
//  Copyright © 2019 Masahiro Tamamura. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MiniPlayerTabBar: UITabBar
-(id)initWithFrame:(CGRect)frame;
- (CGSize)sizeThatFits:(CGSize)size;

@end
