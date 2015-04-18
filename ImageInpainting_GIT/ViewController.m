//
//  ViewController.m
//  ImageInpainting
//
//  Created by 钟路成 on 15/4/6.
//  Copyright (c) 2015年 钟路成. All rights reserved.
//

#import "ViewController.h"
#import "MainView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    MainView * myView = [[MainView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,self.view.bounds.origin.y+20, self.view.bounds.size.width, self.view.bounds.size.height) ];
    
    //UIImage *myImageObj = [UIImage imageNamed:@"Cloth.png"];
    self.view = myView;
    //UIImageView * zoomView = [[UIImageView alloc] initWithImage:myImageObj];
    //[self.view addSubview:zoomView];
    //[self.view addSubview:myView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
