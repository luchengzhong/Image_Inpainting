//
//  SelectedRegion.h
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/7.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum Direction {Horizontal,Vertical};
struct Range {
    NSInteger startPosition;
    NSInteger endPosition;
};
typedef struct Range Range;


@interface SelectedRegion : NSObject
@property (nonatomic) NSMutableArray* rangeOfRows;
@property (nonatomic) NSMutableArray* rangeOfColumns;
@property NSInteger width;
@property NSInteger height;

- (void)initialWithSize:(NSInteger)width Height:(NSInteger)height;
- (void)extendWithRect:(CGRect)rect;
- (void)extendWithLine:(Range)size Index:(NSInteger)index Direction:(enum Direction) direction;
@end
