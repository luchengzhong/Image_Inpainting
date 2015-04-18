//
//  MainView.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/6.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "MainView.h"

@interface MainView()
@property (nonatomic,assign)CGRect curRect;
@property (nonatomic,assign)NSUInteger width;
@property BOOL isEnd;
@end

@implementation MainView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //_lineWidth = 10.0f;
        // _lineColor = [UIColor redColor];
        _width=12;
        UIImage *myImageObj = [UIImage imageNamed:@"Bg.jpeg"];
        _myImage =myImageObj;
        _regionInfo = [[SelectedRegion alloc] init];
        [_regionInfo initialWithSize:_myImage.size.width Height:_myImage.size.height];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    /*UIBezierPath* p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(100,100,100,100)];
     
     [[UIColor blueColor] setFill];
     
     [p fill];
     // NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Cloth.png" ofType:@"png"];
     //UIImage *myImageObj = [[UIImage alloc] initWithContentsOfFile:@"Cloth.png"];
     
     // Store the image into a property of type UIImage *
     // for use later in the class's drawRect: method.
     //CGRect imageRect = CGRectMake(100, 0.0, myImageObj.size.width, myImageObj.size.height);
     //UIGraphicsBeginImageContextWithOptions(myImageObj.size, NO, 1.0);
     //[myImageObj drawInRect:imageRect];
     //_myImage = UIGraphicsGetImageFromCurrentImageContext();
     //UIGraphicsEndImageContext();
     
     UIImage *myImageObj = [UIImage imageNamed:@"Cloth.png"];
     
     CGImageRef imageRef = [myImageObj CGImage];
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     
     int width=(int)CGImageGetWidth(imageRef);
     int height=(int)CGImageGetHeight(imageRef);
     NSUInteger bytesPerPixel=4;
     NSUInteger bytesPerRow=bytesPerPixel*width;
     NSUInteger bitsPerComponent = 8;
     
     unsigned char * imagedata=(unsigned char*)calloc(width*height*bytesPerPixel,sizeof(unsigned char));
     
     CGContextRef cgcnt = CGBitmapContextCreate(imagedata,
     width,
     height,
     bitsPerComponent,
     bytesPerRow,
     colorSpace,
     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
     //CGContextRef cgctx = CreateRGBABitmapContext(imageRef);
     //将图像写入一个矩形
     CGRect therect = CGRectMake(0, 0, width, height);
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextScaleCTM(context, 1.0, -1.0);
     CGContextTranslateCTM(context, 0, -height);
     CGContextDrawImage(context, therect, imageRef);
     
     CGContextDrawImage(cgcnt, therect, imageRef);
     imagedata =CGBitmapContextGetData(cgcnt);
     //  imagedata = CGBitmapContextGetData(cgcnt);//这句不知道要不要，求高手指点
     
     //    释放资源
     //CGColorSpaceRelease(colorSpace);
     //CGContextRelease(cgcnt);
     
     int a=imagedata[10];
     int b=a;*/
    /*UIGraphicsBeginImageContextWithOptions(CGSizeMake(100,100), NO, 0);
     
     CGContextRef con = UIGraphicsGetCurrentContext();
     
     CGContextAddEllipseInRect(con, CGRectMake(0,_count++,100,100));
     
     CGContextSetFillColorWithColor(con, [UIColor blueColor].CGColor);
     
     CGContextFillPath(con);
     
     UIImage* im = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     CGRect imageRect = CGRectMake(100, 0.0, im.size.width, im.size.height);
     
     [im drawInRect:imageRect];*/
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 0.5, 0.5);
    
    
    // Store the image into a property of type UIImage *
    // for use later in the class's drawRect: method.
    CGRect imageRect = CGRectMake(0, 0, _myImage.size.width, _myImage.size.height);
    [_myImage drawInRect:imageRect];
    
    if(!_isEnd){
        UIBezierPath* p = [UIBezierPath bezierPathWithRect:_curRect];
        
        [[UIColor grayColor] setFill];
        
        [p fill];
    }
    //CGContextRef con = UIGraphicsGetCurrentContext();
    //CGContextShowTextAtPoint (con, 40, 300, "Quartz 2D", 9); // 10
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isEnd=false;
    UITouch *touch = [touches anyObject];
    CGPoint location =[touch locationInView:self];
    
    _curRect = CGRectMake(location.x*2-_width, location.y*2-_width, _width*2, _width*2);
    CGRect tempRect= CGRectMake(location.x-_width/2,location.y-_width/2, _width, _width);
    [_regionInfo extendWithRect:_curRect];
    //[self setNeedsDisplay];
    [self setNeedsDisplayInRect:tempRect];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UIImage *myImageObj = [UIImage imageNamed:@"Bg.jpeg"];
    _myImage = [self recaculateImage:_myImage MaskRegion:_regionInfo];
    _isEnd=true;
    [self setNeedsDisplay];
    _regionInfo = [[SelectedRegion alloc] init];
    [_regionInfo initialWithSize:_myImage.size.width Height:_myImage.size.height];
}

- (UIImage*)recaculateImage:(UIImage*) sourceImage MaskRegion:(SelectedRegion*) region{
    UIImage* resultImage;
    ImageHandler *ih = [[ImageHandler alloc] init];
    resultImage = [ih recaculateImage:sourceImage MaskRegion:region];
    return resultImage;
}
@end
