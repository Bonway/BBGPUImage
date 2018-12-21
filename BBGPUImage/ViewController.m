//  希望您的举手之劳，能为我点颗赞，谢谢~
//  代码地址: https://github.com/Bonway/BBGPUImage
//  BBGPUImage
//  Created by Bonway on 2016/3/17.
//  Copyright © 2016年 Bonway. All rights reserved.
//

#import "ViewController.h"

#import <GPUImage/GPUImage.h>
#import "BBGPUImageBeautifyFilter.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;


@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;


@property (strong,nonatomic)GPUImageFilterGroup *filterGroup;
@property (strong,nonatomic)GPUImagePicture *pic;
@property (nonatomic)float senderValue1;
@property (nonatomic)float senderValue2;

@property (strong,nonatomic)GPUImageBrightnessFilter *filter2;
@property (strong,nonatomic)BBGPUImageBeautifyFilter *filter1;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"BBBPUImage";
    
    [self loadBBGPUImage];
}


//磨皮
- (IBAction)slider1Changed:(UISlider *)sender {
    
    self.senderValue1 = sender.value;
    self.filter1.intensity = self.senderValue1;
    [self.pic processImage];
    [self.filterGroup useNextFrameForImageCapture];
    
    self.imgView.image = [self.filterGroup imageFromCurrentFramebuffer];
    
}

//美白
- (IBAction)slider2Changed:(UISlider *)sender {
    
    self.senderValue2 = sender.value;
    self.filter2.brightness = self.senderValue2;
    [self.pic processImage];
    [self.filterGroup useNextFrameForImageCapture];
    self.imgView.image = [self.filterGroup imageFromCurrentFramebuffer];
    
}


-(void)loadBBGPUImage {
    
    self.pic = [[GPUImagePicture alloc] initWithImage:[self fixOrientation:self.imgView.image] smoothlyScaleOutput:YES];
    self.filterGroup = [[GPUImageFilterGroup alloc] init];
    [self.pic addTarget:self.filterGroup];
    
    self.filter1 = [[BBGPUImageBeautifyFilter alloc] init];
    [self.filter1 forceProcessingAtSize:[self fixOrientation:self.imgView.image].size];
    self.filter2 = [[GPUImageBrightnessFilter alloc] init];
    [self.filter2 forceProcessingAtSize:[self fixOrientation:self.imgView.image].size];
    [self addGPUImageFilter:self.filter1];
    [self addGPUImageFilter:self.filter2];
}

//添加到滤镜组

- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter

{
    [self.filterGroup addFilter:filter];//滤镜组添加滤镜
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;//新的结尾滤镜
    NSInteger count =self.filterGroup.filterCount;//滤镜组里面的滤镜数量
    if (count ==1) {
        self.filterGroup.initialFilters =@[newTerminalFilter];//在组里面处理滤镜
        self.filterGroup.terminalFilter = newTerminalFilter;//最后一个滤镜，即最上面的滤镜
    } else {
        GPUImageOutput<GPUImageInput> *terminalFilter = self.filterGroup.terminalFilter;
        
        NSArray *initialFilters = self.filterGroup.initialFilters;
        [terminalFilter addTarget:newTerminalFilter];//逐层吧新的滤镜加到组里最上面
        self.filterGroup.initialFilters =@[initialFilters[0]];
        self.filterGroup.terminalFilter = newTerminalFilter;
    }
}

//防止使用GPUImage自动旋转90度
- (UIImage *)fixOrientation:(UIImage *)img {
    if (img.imageOrientation == UIImageOrientationUp) {
        return img;
    }
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    [img drawInRect:rect];
    
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
