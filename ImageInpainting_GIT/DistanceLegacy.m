//
//  DistanceRecord.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/15.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "DistanceLegacy.h"

@implementation DistanceLegacy
-(void)initWithInfo:(NSInteger)x Y:(NSInteger)y Size:(NSInteger)size{
    _x=x;
    _y=y;
    _size=size;
    _disMatrix = (int***)malloc(sizeof(int**)*_size);
    for(int i=0;i<_size;i++){
        _disMatrix[i] =(int**)malloc(sizeof(int*)*_size);
        for(int j=0;j<_size;j++){
            _disMatrix[i][j]=NULL;
        }
    }
}

-(void)addRecord:(NSInteger)offsetX offsetY:(NSInteger)offsetY Value:(int*)value{
    _disMatrix[offsetY][offsetX]=value;
}

-(void)freeMemory{
    if(_disMatrix==NULL){
        return;
    }
    for(int i=0;i<_size;i++){
        if(_disMatrix[i]!=NULL){
            for(int j=0;j<_size;j++){
                if(_disMatrix[i][j]!=NULL){
                    free(_disMatrix[i][j]);
                    _disMatrix[i][j]=NULL;
                }
            }
            free(_disMatrix[i]);
            _disMatrix[i]=NULL;
        }
    }
    free(_disMatrix);
    _disMatrix=NULL;
}
-(void)dealloc{
    if(_disMatrix!=NULL){
        [self freeMemory];
    }
}
@end
