//
//  HMBLEPeripherHandel.m
//  HMBluePeripheral
//
//  Created by occ on 2017/2/21.
//  Copyright © 2017年 occ. All rights reserved.
//

#import "HMBLEPeripherHandel.h"

#define TRANSFER_SERVICE_UUID  @"0FB51F75-C9D5-45DC-BA61-065BD4A5E3E8"

//特征
#define TRANSFER_CHARACTERISTIC_UP_UUID @"B678C8E2-9B1A-4952-A320-EF6D42F0831A"
#define TRANSFER_CHARACTERISTIC_Center_UUID @"3146C446-1565-452A-8A3A-0093E653DCA7"
#define TRANSFER_CHARACTERISTIC_Down_UUID @"0430E936-1610-4EB0-9D97-D37F4EF56B39"
#define TRANSFER_CHARACTERISTIC_Image_UUID @"303DFE10-2C5D-4249-93A9-9B494F174E2F"

@implementation HMBLEPeripherHandel

+(HMBLEPeripherHandel *)sharedHMBLEPeripherHandel {
    
    static HMBLEPeripherHandel *sharedCenter = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken,^{
        sharedCenter = [[self alloc] init];
        [sharedCenter initObject];
    });
    return  sharedCenter;
}

-(void)initObject {
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.peripheralManager.delegate = self;
    
}




//===============================================================//
//===============================================================//


//1 查看设备是否支持 ，若支持则创建 服务和特征
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    NSString *statStr = [NSString stringWithFormat:@"设备状态： %li",(long)peripheral.state];
    if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        NSLog(@"该设备不支持");
        statStr = [statStr stringByAppendingString:@"该设备不支持"];
    }
    
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"该设备不支持,检查是否打开蓝牙");
        return;
    }
    
    //一组特征值
    _upCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UP_UUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    _centerCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_Center_UUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    _downCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_Down_UUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
    _imageCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_Image_UUID] properties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    //一个服务
    transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID] primary:YES];
    
    //一个服务中添加多个特征值
    NSArray *characters = [[NSArray alloc] initWithObjects:_upCharacteristic,_centerCharacteristic,_downCharacteristic,_imageCharacteristic, nil];
    [transferService setCharacteristics:characters];
    
    // 2 添加一个服务
    //服务添加到周边管理者（Peripheral Manager）是用于发布服务。一旦完成这个，周边管理者会通知他的代理方法-peripheralManager:didAddService:error:。现在，如果没有Error，你可以开始广播服务了：
    [self.peripheralManager addService:transferService];
    
}



// 3 会监听didAddService
-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"添加服务");
    if (error != nil) {
        NSLog(@"添加服务失败： %@",error.localizedDescription);
        
    } else {
        
        //[peripheralManager startAdvertising:[[NSDictionary alloc] initWithObjectsAndKeys:@"ICServer",CBAdvertisementDataLocalNameKey,[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID],CBAdvertisementDataServiceUUIDsKey, nil]];
        
        // 开始广播
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataLocalNameKey : @"Service_name", CBAdvertisementDataServiceUUIDsKey :@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    }
}

// 4 会监听DidStartAdvertising
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
    }else {
        NSLog(@"外设设置成功 advertising successed");
    }
}

//当中央端连接上了此设备并订阅了特征时会回调 didSubscribeToCharacteristic
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"中心已经预定了特征 --- %@",characteristic);
}

//当中央端取消订阅时会调用didUnsubscribeFromCharacteristic
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"中心没有从特征预定 -- %@",characteristic);
}


//当接收到中央端读的请求时会调用didReceiveReadRequest
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    //如果特征值的UUID匹配，下一步就是确保请求所读的数据不越界
    if ([request.characteristic.UUID isEqual:self.imageCharacteristic.UUID]) {
        if (request.offset > self.imageCharacteristic.value.length) {
            [self.peripheralManager respondToRequest:request
                                       withResult:CBATTErrorInvalidOffset];
            return;
        }
        //如果请求的偏移量没有越界，那么设置请求的值 ????
        //request.value = [self.imageCharacteristic.value subdataWithRange:NSMakeRange(request.offset,self.imageCharacteristic.value.length - request.offset)];
        //[self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];

    }
    
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"--- 终端读：%@",dataString);
        
        [request setValue:data];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    } else {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorReadNotPermitted];
    }
}

//当接收到中央端写的请求时会调用didReceiveWriteRequest
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    
    //这里同样需要注意请求的偏移量问题，
    CBATTRequest *request = requests[0];
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        CBMutableCharacteristic *c = (CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        
        NSData *data = c.value;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@" 终端写：%@",dataString);

        if (data) {//接收数据判断处理
            
            if ([c.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_Image_UUID]]) {
                if (data.length >= 512) {
                    if (self.receiveData == nil) {
                        self.receiveData = [[NSMutableData alloc] initWithData:data];
                    } else {
                        [self.receiveData appendData:data];
                    }
                } else {
                    //可以根据不同需求设置 不同种类的结束表示
                    NSString *exoString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if ([exoString isKindOfClass:[NSString class]]) {
                        if ([exoString isEqualToString:@"exo"]) {
                            
                            if (self.receiveData == nil) {
                                self.receiveData = [[NSMutableData alloc] initWithData:data];
                            }
                            if (self.resultBlock) {
                                self.resultBlock(@{@"data":self.receiveData,@"state":exoString});
                            }
                            self.receiveData = nil;
                        }
                    }
                    [self.receiveData appendData:data];
                }
                
            } else {}
        }
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    } else {
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}

//updateValue:forCharacteristic:onSubscribedCentrals: 这个方法返回Boolean值，指明数据是否成功发送。如果底层的队列正在传输数据，这个方法就会返回NO。当传输队列重新变为空闲时，则会调用peripheral manager的代理方法peripheralManagerIsReadyToUpdateSubscribers: ，这时你就可以利用这个代理重新发送数据，而不需要重新调用updateValue:forCharacteristic:onSubscribedCentrals: 方法

//局限于特征值数据大小的限制，并不是所有数据都能用通知来传递。这种情况下，应该由central端通过调用CBPeripheral的readValueForCharacteristic: 方法来获取整个数据。
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@" ----☸️☸️☸️    peripheralManagerIsReadyToUpdateSubscribers");
}


- (BOOL)updateValue:(NSData *)value characteristic:(CBMutableCharacteristic *)characteristic {
    
    if (value && characteristic) {
       return [self.peripheralManager updateValue:value forCharacteristic:characteristic onSubscribedCentrals:nil];
    }
    return NO;
}

@end
