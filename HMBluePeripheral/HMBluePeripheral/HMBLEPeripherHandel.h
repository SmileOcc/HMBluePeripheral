//
//  HMBLEPeripherHandel.h
//  HMBluePeripheral
//
//  Created by occ on 2017/2/21.
//  Copyright © 2017年 occ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef  void (^ResultBlock)(NSDictionary *result);

@interface HMBLEPeripherHandel : NSObject<CBPeripheralManagerDelegate>{
        
    CBMutableService        *transferService;
    NSData                  *dataToSend;
    NSInteger               sendDataIndex;
}

+(HMBLEPeripherHandel *)sharedHMBLEPeripherHandel;

@property (nonatomic,strong) CBPeripheralManager *peripheralManager;

//一组特征值
@property (nonatomic, strong) CBMutableCharacteristic *upCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *centerCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *downCharacteristic;
@property (nonatomic, strong) CBMutableCharacteristic *imageCharacteristic;

@property (nonatomic, strong) ResultBlock resultBlock;
@property (nonatomic, strong) NSMutableData *receiveData;

- (BOOL)updateValue:(NSData *)value characteristic:(CBMutableCharacteristic *)characteristic;



@end
