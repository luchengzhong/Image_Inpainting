//
//  SelectedRegion.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/7.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "SelectedRegion.h"

@implementation SelectedRegion
- (void)initialWithSize:(NSInteger)width Height:(NSInteger)height{
    if (_rangeOfRows == nil) {
        _rangeOfRows = [NSMutableArray array];
    }
    if (_rangeOfColumns == nil) {
        _rangeOfColumns = [NSMutableArray array];
    }
    for(int i=0;i<width;i++){
        NSMutableArray* rangeOfEach = [NSMutableArray array];
        [_rangeOfColumns addObject:rangeOfEach];
    }
    for(int i=0;i<height;i++){
        NSMutableArray* rangeOfEach = [NSMutableArray array];
        [_rangeOfRows addObject:rangeOfEach];
    }
    _width=width;
    _height=height;
}

- (void)extendWithRect:(CGRect) rect{
    Range tempRange;
    for(NSInteger i=rect.origin.x;i<rect.size.width+rect.origin.x;i++){
        tempRange.startPosition = rect.origin.y;
        tempRange.endPosition = rect.origin.y + rect.size.height;
        [self extendWithLine:tempRange Index:i Direction:Vertical];
    }
    
    for(NSInteger i=rect.origin.y;i<rect.size.height+rect.origin.y;i++){
        tempRange.startPosition = rect.origin.x;
        tempRange.endPosition = rect.origin.x + rect.size.width;
        [self extendWithLine:tempRange Index:i Direction:Horizontal];
    }
}
- (void)extendWithLine:(Range)range Index:(NSInteger)index Direction:(enum Direction) direction{
    NSMutableArray* ranges;
    if(direction == Horizontal){
        ranges=_rangeOfRows;
    }else{
        ranges=_rangeOfColumns;
    }
    if(index >= [ranges count]){
        return;
    }
    
    NSMutableArray* rangeOfEach = ranges[index];
    NSInteger length = [rangeOfEach count];
    
    Range replaceRange;
    if(length == 0){
        replaceRange.startPosition = range.startPosition;
        replaceRange.endPosition = range.endPosition;
        [rangeOfEach addObject:[NSValue value:&replaceRange withObjCType:@encode(Range)]];
    }else{
        NSInteger startIndex = length;
        NSInteger endIndex = length-1;
        
        Boolean foundStart = false;
        Boolean foundEnd = false;
        
        NSValue* tempRef;
        Range tempRange;
        for(NSInteger i=0;i<length;i++){
            tempRef = rangeOfEach[i];
            [tempRef getValue:&tempRange];
            if(!foundStart && (range.startPosition <= tempRange.startPosition)){
                startIndex = i;
                foundStart=true;
            }
            
            if(!foundEnd && (range.endPosition <= tempRange.startPosition)){
                endIndex = i-1;
                foundEnd=true;
            }
        }
        
        if(!foundStart){
            [rangeOfEach addObject:[NSValue value:&range withObjCType:@encode(Range)]];
        }else if(endIndex == startIndex-1){
            [rangeOfEach insertObject:[NSValue value:&range withObjCType:@encode(Range)] atIndex:startIndex];
        }else{
            tempRef = rangeOfEach[startIndex];
            [tempRef getValue:&tempRange];
            replaceRange.startPosition = MIN(tempRange.startPosition, range.startPosition);
            
            tempRef = rangeOfEach[endIndex];
            [tempRef getValue:&tempRange];
            replaceRange.endPosition = MAX(tempRange.endPosition, range.endPosition);
            
            NSRange removeRange;
            removeRange.location =startIndex;
            removeRange.length = endIndex-startIndex+1;
            [rangeOfEach removeObjectsInRange:removeRange];
            
            if(startIndex >= [rangeOfEach count]){
                [rangeOfEach addObject:[NSValue value:&replaceRange withObjCType:@encode(Range)]];
            }else{
                [rangeOfEach insertObject:[NSValue value:&replaceRange withObjCType:@encode(Range)] atIndex:startIndex];
            }
        }
    }
}
@end
