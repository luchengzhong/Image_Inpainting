//
//  PixelInfo.h
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/8.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectedRegion.h"
#import "DistanceLegacy.h"
#import <UIKit/UIKit.h>

@interface PixelInfo : NSObject
@property int matchScale;
@property int neigbourScale;

- (void)recalculateColor:(uint32_t*)buffer Region:(SelectedRegion*)region;
- (void)processEachLine:(enum Direction)direction Region:(SelectedRegion*)region Level:(int)curLevel;
- (uint32_t)getBetterColor:(CGPoint)p Direction:(enum Direction)direc isInverted:(BOOL)isNegDirection;
- (CGFloat)euclidanDistanceBetween:(CGPoint)p1 Another:(CGPoint)p2 Direction:(enum Direction)direc isInverted:(BOOL)isNegDirection;
- (NSInteger)colorDistance:(CGPoint)p1 Another:(CGPoint)p2;
- (BOOL)isInside:(int)x Y:(int)y;
- (BOOL)isInMasked:(int)x Y:(int)y;
@end
