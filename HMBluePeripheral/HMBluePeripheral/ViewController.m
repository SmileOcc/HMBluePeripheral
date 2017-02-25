//
//  ViewController.m
//  HMBluePeripheral
//
//  Created by FaceStar on 15-3-1.
//  Copyright (c) 2015年 occ. All rights reserved.
//

#import "ViewController.h"
#import "HMBLEPeripherHandel.h"

#define TRANSFER_SERVICE_UUID  @"0FB51F75-C9D5-45DC-BA61-065BD4A5E3E8"
//特征
#define TRANSFER_CHARACTERISTIC_UP_UUID @"B678C8E2-9B1A-4952-A320-EF6D42F0831A"
#define TRANSFER_CHARACTERISTIC_Center_UUID @"3146C446-1565-452A-8A3A-0093E653DCA7"
#define TRANSFER_CHARACTERISTIC_Down_UUID @"0430E936-1610-4EB0-9D97-D37F4EF56B39"
#define TRANSFER_CHARACTERISTIC_Image_UUID @"303DFE10-2C5D-4249-93A9-9B494F174E2F"

#define WEAK_SELF                   __weak typeof(self) weak_self = self;
#define WEAK_OBJECT(weak_obj, obj)  __weak typeof(obj) weak_obj = obj;

@interface ViewController ()

@property (nonatomic, strong) UITextView          *textView;
@property (nonatomic, strong) UIImageView         *testImageView;
@property (nonatomic, strong) UIButton            *upButton;
@property (nonatomic, strong) UIButton            *downButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    
    WEAK_SELF
    [HMBLEPeripherHandel sharedHMBLEPeripherHandel].resultBlock = ^(NSDictionary *result) {
        [weak_self handleResutl:result];
    };
}

- (void)initView {
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 60)];
    self.textView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.textView];
    
    self.testImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2.0, 160, 100, 100)];
    self.testImageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.testImageView];
    
    
    self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.upButton setTitle:@"上" forState:UIControlStateNormal];
    self.upButton.frame = CGRectMake((self.view.bounds.size.width - 40) / 2.0, 270, 40, 40);
    self.upButton.backgroundColor = [UIColor orangeColor];
    [self.upButton addTarget:self action:@selector(actionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.upButton];
    
    self.downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downButton setTitle:@"下" forState:UIControlStateNormal];
    self.downButton.frame = CGRectMake((self.view.bounds.size.width - 40) / 2.0, 320, 40, 40);
    self.downButton.backgroundColor = [UIColor orangeColor];
    [self.downButton addTarget:self action:@selector(actionDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downButton];

}

- (void)handleResutl:(NSDictionary *)resultDic {
    NSString *stateString = resultDic[@"state"];
    if ([stateString isEqualToString:@"exo"]) {
        NSData *data = resultDic[@"data"];
        UIImage *testImg = [UIImage imageWithData:data];
        self.testImageView.image = testImg;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)actionUp:(UIButton *)sender {
    
    NSData *testData = [@"U" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    BOOL didSend = [[HMBLEPeripherHandel sharedHMBLEPeripherHandel] updateValue:testData characteristic:[HMBLEPeripherHandel sharedHMBLEPeripherHandel].upCharacteristic];
    
    if (didSend) {
        NSLog(@"start send success");
    }
}


- (void)actionDown:(UIButton *)sender {
    
    NSData *testData = [@"D" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    BOOL didSend = [[HMBLEPeripherHandel sharedHMBLEPeripherHandel] updateValue:testData characteristic:[HMBLEPeripherHandel sharedHMBLEPeripherHandel].centerCharacteristic];
    
    if (didSend) {
        NSLog(@"start send success");
    }
}

@end
