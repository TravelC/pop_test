//
//  FlowViewLayout.h
//  UDN_VOD
//
//  Created by udntv on 2014/4/18.
//  Copyright (c) 2014年 pd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlowViewLayoutDelegate

@optional
-(NSInteger) settingValueWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface FlowViewLayout : UICollectionViewLayout
{
    __weak id<FlowViewLayoutDelegate> delegate;
    NSInteger _mode ;
}

@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) NSInteger numberOfColumns;

+(CGFloat) getWidthWithHeight:(CGFloat) height;


@end
