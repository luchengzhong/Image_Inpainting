//
//  DistanceRecord.h
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/15.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistanceLegacy : NSObject
@property NSInteger x;
@property NSInteger y;
@property int*** disMatrix;
@property NSInteger size;

-(void) initWithInfo:(NSInteger)x Y:(NSInteger)y Size:(NSInteger)size;
-(void) addRecord:(NSInteger)offsetX offsetY:(NSInteger)offsetY Value:(int*)value;
-(void) freeMemory;
@end
