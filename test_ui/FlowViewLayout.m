//
//  FlowViewLayout.m
//  UDN_VOD
//
//  Created by udntv on 2014/4/18.
//  Copyright (c) 2014年 pd. All rights reserved.
//

#import "FlowViewLayout.h"

static NSString * const BHPhotoAlbumLayoutPhotoCellKind = @"PhotoCell";

@interface FlowViewLayout()
@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

static NSInteger preHeight = 0;
@implementation FlowViewLayout


#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
}

- (void)prepareLayout
{
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSInteger processIdx = 0;
        UICollectionViewLayoutAttributes *itemAttributes = nil;
        while(processIdx < itemCount)
        {

                indexPath = [NSIndexPath indexPathForItem:processIdx inSection:section];
                itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                itemAttributes.frame = [self frameForAlbumPhotoWithIndex:processIdx];
                cellLayoutInfo[indexPath] = itemAttributes;
                processIdx++;
        }
    }
    
    
    newLayoutInfo[BHPhotoAlbumLayoutPhotoCellKind] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}



- (CGRect)frameForAlbumPhotoWithIndex:(NSInteger) idx
{
    CGFloat originX =0, originY = 0, originWidth = 0, originHeight = 0;
    
    CGFloat viewWidth  = [FlowViewLayout getWidthWithHeight: self.collectionView.frame.size.height];
    originX = idx * viewWidth;
    originY = 0;
    originWidth = viewWidth;
    originHeight = self.collectionView.frame.size.height;

    return CGRectMake(originX, originY, originWidth, originHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier,
                                                         NSDictionary *elementsInfo,
                                                         BOOL *stop) {
        [elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                          UICollectionViewLayoutAttributes *attributes,
                                                          BOOL *innerStop) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }];
    }];
    
    return allAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutInfo[BHPhotoAlbumLayoutPhotoCellKind][indexPath];
}

- (CGSize)collectionViewContentSize
{
    CGFloat viewWidth = [FlowViewLayout getWidthWithHeight: self.collectionView.frame.size.height];
    return CGSizeMake([self.collectionView numberOfItemsInSection:0] * viewWidth , self.collectionView.frame.size.height);
}

+(CGFloat) getWidthWithHeight:(CGFloat) height;
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return height * screenWidth / screenHeight;
}

@end
