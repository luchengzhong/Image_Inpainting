//
//  PixelInfo.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/8.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "PixelInfo.h"
@interface PixelInfo()
@property BOOL* isMasked;
@property BOOL* isCalculated;
@property CGFloat* euclidanDistance;
@property NSMutableArray* disLegacies;
@property uint32_t* pixelColor;
@property uint32_t** pixelColorD2;
@property NSInteger width;
@property NSInteger height;
@property int maxRange;
@property int loopTime;
@end
@implementation PixelInfo
- (void)recalculateColor:(uint32_t*)buffer Region:(SelectedRegion*)region{
    _maxRange=0;
    _matchScale=7;
    _neigbourScale=3;
    _loopTime=4;
    
    _pixelColor=buffer;
    _width=region.width;
    _height=region.height;
    
    _pixelColorD2 = (uint32_t**)malloc(sizeof(uint32_t*) * _height);
    _disLegacies = [NSMutableArray array];
    for(int i=0;i<_height;i++){
        _pixelColorD2[i] =(uint32_t*)malloc(sizeof(uint32_t) * _width);
        memcpy(_pixelColorD2[i], _pixelColor+i*_width, sizeof(uint32_t) * _width);
        [_disLegacies addObject:[NSMutableArray array]];
        for(int j=0;j<_width;j++){
            [_disLegacies[i] addObject:[NSNull null]];
        }
    }
    
    _isMasked =(BOOL*)malloc(sizeof(BOOL)*_width*_height);
    _isCalculated=(BOOL*)malloc(sizeof(BOOL)*_width*_height);
    _euclidanDistance = (CGFloat*)malloc(sizeof(CGFloat)*_width*_height);
    
    memset(_isMasked, false, sizeof(BOOL)*_width*_height);
    
    Range tempRange;
    for(NSInteger i=0;i<_height;i++){
        NSMutableArray* rangeOfEach = region.rangeOfRows[i];
        NSInteger count=[rangeOfEach count];
        for(int p=0;p<count;p++){
            NSValue* eachRange = rangeOfEach[p];
            [eachRange getValue:&tempRange];
            
            int coloNum= (int)tempRange.startPosition;
            int count = (int)(tempRange.endPosition-tempRange.startPosition+1);
            memset(_isMasked+i*_width+coloNum, true, count*sizeof(BOOL));
            _maxRange = MAX(_maxRange, count);
            for(int j=coloNum;j<=tempRange.endPosition;j++){
                _euclidanDistance[i*_width+j]=10000;
            }
        }
    }
    for(int i=0;i<_loopTime;i++){
        memset(_isCalculated, false, sizeof(BOOL)*_width*_height);
        _disLegacies=nil;
        _disLegacies = [NSMutableArray array];
        for(int i=0;i<_height;i++){
            [_disLegacies addObject:[NSMutableArray array]];
            for(int j=0;j<_width;j++){
                [_disLegacies[i] addObject:[NSNull null]];
            }
        }
        _maxRange = (_maxRange+1)/2;
        int curLevel;
        for(curLevel=0;curLevel<=_maxRange;curLevel++){
            [self processEachLine:Horizontal Region:region Level:curLevel];
            [self processEachLine:Vertical Region:region Level:curLevel];
        }
        [self freeDisLegacy:region];
    }
    
    for(int i=0;i<_height;i++){
        memcpy( _pixelColor+i*_width,_pixelColorD2[i], sizeof(uint32_t) * _width);
        free(_pixelColorD2[i]);
    }
    free(_pixelColorD2);
    free(_euclidanDistance);
    free(_isMasked);
    free(_isCalculated);
}
-(void)freeDisLegacy:(SelectedRegion*)region{
    //Range tempRange;
    for(NSInteger j=0;j<_height;j++){
        /*for(NSValue* vRange in region.rangeOfRows[j]){
         [vRange getValue:&tempRange];
         int coloNum= (int)tempRange.startPosition;
         int endNum = (int)tempRange.endPosition;
         for(int k=coloNum;k<=endNum;k++){
         id temp=(id)_disLegacies[j][k];
         if(temp != [NSNull null]){
         [(DistanceLegacy*)temp freeMemory];
         }
         }
         }*/
        for(int i=0;i<_width;i++){
            id temp=(id)_disLegacies[j][i];
            if(temp != [NSNull null]){
                [(DistanceLegacy*)temp freeMemory];
            }
        }
    }
}
- (void)processEachLine:(enum Direction)direction Region:(SelectedRegion*)region Level:(int)curLevel{
    NSInteger lineNum;
    CGPoint p;
    Range tempRange;
    NSMutableArray* ranges;
    if(direction == Horizontal){
        ranges=region.rangeOfRows;
        lineNum=_height;
    }else{
        ranges=region.rangeOfColumns;
        lineNum=_width;
    }
    for(NSInteger i=0;i<lineNum;i++){
        for(NSValue* vRange in ranges[i]){
            [vRange getValue:&tempRange];
            if(tempRange.startPosition+curLevel <= tempRange.endPosition-curLevel){
                if(direction == Horizontal){
                    p.x = tempRange.startPosition+curLevel;
                    p.y = i;
                }else{
                    p.y = tempRange.startPosition+curLevel;
                    p.x = i;
                }
                //_pixelColor[(int)(p.y*_width+p.x)] = [self getBetterColor:p];
                if(!_isCalculated[(int)(p.y*_width+p.x)]){
                    _pixelColorD2[(int)p.y][(int)p.x] = [self getBetterColor:p Direction:direction isInverted:false];
                }
                if(tempRange.startPosition+curLevel < tempRange.endPosition-curLevel){
                    if(direction == Horizontal){
                        p.x = tempRange.endPosition-curLevel;
                    }else{
                        p.y = tempRange.endPosition-curLevel;
                    }
                    //_pixelColor[(int)(p.y*_width+p.x)] = [self getBetterColor:p];
                    if(!_isCalculated[(int)(p.y*_width+p.x)]){
                        _pixelColorD2[(int)p.y][(int)p.x] = [self getBetterColor:p Direction:direction isInverted:true];
                    }
                }
            }
        }
    }
}
- (uint32_t)getBetterColor:(CGPoint)p Direction:(enum Direction)direc isInverted:(BOOL)isNegDirection{
    uint32_t newColor=0;
    //int index = 0;
    int offsetX;
    int offsetY;
    CGPoint p2;
    CGFloat minDistance=MAXFLOAT;
    CGFloat tempDis;
    int newx=0;
    int newy=0;
    
    DistanceLegacy* selfDislegacy = [DistanceLegacy new];
    [selfDislegacy initWithInfo:p.x Y:p.y Size:_matchScale*2+1];
    NSMutableArray* tempArray = (NSMutableArray*)_disLegacies[(int)p.y];
    
    [tempArray replaceObjectAtIndex:(int)p.x withObject:selfDislegacy];
    
    for(offsetX = -_matchScale;offsetX <= _matchScale;offsetX++){
        for(offsetY = -_matchScale;offsetY <= _matchScale;offsetY++){
            p2.x=p.x+offsetX;
            p2.y=p.y+offsetY;
            if([self isInside:p2.x Y:p2.y]){
                if(p.x!=p2.x || p.y!=p2.y){
                    tempDis=[self euclidanDistanceBetween:p Another:p2 Direction:direc isInverted:isNegDirection];
                    if(tempDis<minDistance){
                        //index = p2.y*_width + p2.x;
                        newy=p2.y;
                        newx=p2.x;
                    }
                }else{
                    ((DistanceLegacy*)_disLegacies[(int)p.y][(int)p.x]).disMatrix[_matchScale][_matchScale]=NULL;
                }
            }
        }
    }
    
    _euclidanDistance[(int)(p.y*_width+p.x)] = minDistance;
    //newColor = _pixelColor[index];
    newColor = _pixelColorD2[newy][newx];
    _isCalculated[(int)(p.y*_width+p.x)]=true;
    return newColor;
}
- (CGFloat)euclidanDistanceBetween:(CGPoint)p1 Another:(CGPoint)p2 Direction:(enum Direction)direc isInverted:(BOOL)isNegDirection{
    CGFloat distance = 0;
    int* selfLegacyDis = (int*) malloc(sizeof(int)*_neigbourScale*2);
    int* legacydis;
    int offsetX;
    int offsetY;
    
    int p1X,p1Y,p2X,p2Y;
    CGPoint np1,np2;
    int count = 0;
    
    int previousX=(int)p1.x;
    int previousY=(int)p1.y;
    if(direc == Horizontal){
        if(!isNegDirection){
            previousX--;
        }else{
            previousX++;
        }
    }else{
        if(!isNegDirection){
            previousY--;
        }else{
            previousY++;
        }
    }
    if(_disLegacies[previousY][previousX] != [NSNull null]){
        int startX=-_neigbourScale;
        int startY=-_neigbourScale;
        int endX=_neigbourScale;
        int endY=_neigbourScale;
        DistanceLegacy* dislegacy = (DistanceLegacy*)_disLegacies[previousY][previousX];
        legacydis = dislegacy.disMatrix[(int)(p2.y-p1.y+_matchScale)][(int)(p2.x-p1.x+_matchScale)];
        distance+=legacydis[0];
        
        for(int i=1;i<_neigbourScale*2;i++){
            distance+=legacydis[i];
            selfLegacyDis[i-1] = legacydis[i];
        }
        //free(legacydis);
        if(direc == Horizontal){
            if(!isNegDirection){
                startX=_neigbourScale;
            }else{
                endX=-_neigbourScale;
            }
        }else{
            if(!isNegDirection){
                startY=_neigbourScale;
            }else{
                endY=-_neigbourScale;
            }
        }
        selfLegacyDis[_neigbourScale*2-1]=0;
        int tempDis;
        for(offsetX = startX;offsetX <= endX;offsetX++){
            for(offsetY = startY;offsetY <= endY;offsetY++){
                p1X=p1.x+offsetX;
                p1Y=p1.y+offsetY;
                p2X=p2.x+offsetX;
                p2Y=p2.y+offsetY;
                if([self isInside:p1X Y:p1Y] && [self isInside:p2X Y:p2Y]){
                    np1.x=p1X;
                    np1.y=p1Y;
                    np2.x=p2X;
                    np2.y=p2Y;
                    tempDis=(int)[self colorDistance:np1 Another:np2];
                    distance+=tempDis;
                    selfLegacyDis[_neigbourScale*2-1]+=tempDis;
                    count++;
                }
            }
        }
    }else{
        for(int i=0;i<_neigbourScale*2;i++){
            selfLegacyDis[i] = 0;
        }
        int tempDis;
        for(offsetX = -_neigbourScale;offsetX <= _neigbourScale;offsetX++){
            for(offsetY = -_neigbourScale;offsetY <= _neigbourScale;offsetY++){
                p1X=p1.x+offsetX;
                p1Y=p1.y+offsetY;
                p2X=p2.x+offsetX;
                p2Y=p2.y+offsetY;
                if([self isInside:p1X Y:p1Y] && [self isInside:p2X Y:p2Y]){
                    np1.x=p1X;
                    np1.y=p1Y;
                    np2.x=p2X;
                    np2.y=p2Y;
                    tempDis=(int)[self colorDistance:np1 Another:np2];
                    distance+=tempDis;
                    count++;
                    
                    int offset=offsetX;
                    if(direc == Horizontal){
                        offset =offsetY;
                    }
                    int index=0;
                    if(!isNegDirection){
                        index=offset+_neigbourScale;
                    }else{
                        index=_neigbourScale-offset;
                    }
                    if(index>0){
                        selfLegacyDis[index-1]+=tempDis;
                    }
                }
            }
        }
    }
    if(((DistanceLegacy*)_disLegacies[(int)p1.y][(int)p1.x]).disMatrix[(int)(p2.y-p1.y+_matchScale)][(int)(p2.x-p1.x+_matchScale)] !=NULL){
        free(((DistanceLegacy*)_disLegacies[(int)p1.y][(int)p1.x]).disMatrix[(int)(p2.y-p1.y+_matchScale)][(int)(p2.x-p1.x+_matchScale)]);
    }
    ((DistanceLegacy*)_disLegacies[(int)p1.y][(int)p1.x]).disMatrix[(int)(p2.y-p1.y+_matchScale)][(int)(p2.x-p1.x+_matchScale)] = selfLegacyDis;
    selfLegacyDis=NULL;
    /*if(count == 0){
     distance=10000;
     }else{
     distance/=count;
     }*/
    if([self isInMasked:p2.x Y:p2.y]){
        distance += _euclidanDistance[(int)(p2.y*_width+p2.x)]/100;
    }
    return distance;
}
- (NSInteger)colorDistance:(CGPoint)p1 Another:(CGPoint)p2{
    NSInteger distance=0;
    //uint32_t color1 = _pixelColor[(int)(p1.y*_width+p1.x)];
    //uint32_t color2 = _pixelColor[(int)(p2.y*_width+p2.x)];
    uint32_t color1 = _pixelColorD2[(int)p1.y][(int)p1.x];
    uint32_t color2 = _pixelColorD2[(int)p2.y][(int)p2.x];
    uint8_t *rgbaPixel1 = (uint8_t *)&color1;
    uint8_t *rgbaPixel2 = (uint8_t *)&color2;
    /*for(int i=0;i<4;i++){
     distance += abs(rgbaPixel1[i]-rgbaPixel2[i]);
     }*/
    distance += abs(rgbaPixel1[0]-rgbaPixel2[0]);
    distance += abs(rgbaPixel1[1]-rgbaPixel2[1]);
    distance += abs(rgbaPixel1[2]-rgbaPixel2[2]);
    distance += abs(rgbaPixel1[3]-rgbaPixel2[3]);
    return distance;
}
- (BOOL)isInside:(int)x Y:(int)y{
    if( x<0 || x>=_width || y<0 || y>=_height ){
        return false;
    }
    return true;
}
- (BOOL)isInMasked:(int)x Y:(int)y{
    return _isMasked[y*_width+x];
}
@end
