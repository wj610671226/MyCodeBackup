//
//  ViewController.m
//  LanYa
//
//  Created by wangjie on 2018/3/26.
//  Copyright © 2018年 wangjie. All rights reserved.
//


#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

// 协议数据包类型
typedef NS_ENUM(NSInteger, PackageEnum)
{
    PackageEnumEF1 = 0xA0,
    PackageEnumEF2 = 0xB0,
    PackageEnumEF3 = 0xC0,
    PackageEnumEF4 = 0xD0,
};

NSInteger const KpackageDataLength = 20; // 协议数据包长度

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property(nonatomic, strong)NSMutableArray * peripherals; // 保存被发现的设备
@property(nonatomic, strong)CBCentralManager * manager; // 蓝牙设备管理对象
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 使用系统默认的提示框
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("coreBluetooh", DISPATCH_QUEUE_CONCURRENT)];

    // 关闭系统权限提示
//    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("coreBluetooh", DISPATCH_QUEUE_CONCURRENT) options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    self.peripherals = [NSMutableArray array];
}

#pragma mark - CBCentralManagerDelegate
// 状态已经更新
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"CBManagerStatePoweredOn");
            // 开始扫描
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
}

// 状态将要恢复
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"状态将要恢复");
}

// 发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name.length == 0) { return; }
    // 一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
    // 找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
    //连接设备
    NSLog(@"name = %@", peripheral.name);
    if ([peripheral.name containsString:@"EFSD_11"]) {
        // 找到对应设备停止扫描
        [central stopScan];
        [self.peripherals addObject:peripheral];
        NSLog(@"name = %@", peripheral.name);
        [self.manager connectPeripheral:peripheral options:nil];
    }
   
}

// 失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接失败 - %@  -  失败原因 - %@", peripheral.name, error.localizedDescription);
}

// 已经断开外设
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"设备断开 - %@  -  断开原因 - %@", peripheral.name, error.localizedDescription);
    // 停止扫描
//    [central stopScan];
    // 断开连接
    [central cancelPeripheralConnection:peripheral];
}

// 已经连接到外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接设备成功 - %@  - 成功", peripheral.name);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheralDelegate
// 扫描服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"扫描到服务%@, name = %@", peripheral.services, peripheral.name);
    if (error) {
        NSLog(@"扫描服务错误%@", error.localizedDescription);
        return;
    }
    
    // 遍历外设提供的服务
//    for (CBService * service in peripheral.services) {
//        NSLog(@"服务 - UUID = %@", service.UUID);
//        // 扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
//        [peripheral discoverCharacteristics:nil forService:service];
//    }
    
    // 项目中采用的服务 <CBService: 0x170262180, isPrimary = YES, UUID = FFE0>
    [peripheral discoverCharacteristics:nil forService:peripheral.services.lastObject];
}

// 扫描到Characteristics 发现特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"扫描到Characteristics失败%@", error.localizedDescription);
        return;
    }

    // 获取Characteristic的值，读到数据会进入方法 didUpdateValueForCharacteristic
    for (CBCharacteristic * characteristic in service.characteristics) {
        NSLog(@"扫描特征 - characteristics UUID : %@ -- service UUID :%@", characteristic.UUID, service.UUID);
        // 订阅通知 数据通知会进入：didUpdateValueForCharacteristic方法
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//        [peripheral readValueForCharacteristic:characteristic];
    }
    
    // //搜索Characteristic的Descriptors 读到数据会进入方法didDiscoverDescriptorsForCharacteristic
//    for (CBCharacteristic * characteristic in service.characteristics){
//        [peripheral discoverDescriptorsForCharacteristic:characteristic];
//    }

    // 发送数据 wifi name
    [self sendWifiNameData:peripheral characteristic:service.characteristics.lastObject name:@"EF" type:PackageEnumEF1];
}

// 打印Characteristic， 读取数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 打印出characteristic的UUID和值
    // !注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSString * value = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    NSLog(@"读取 数据 - characteristic %@ - %@", characteristic.value, value);
    
    if ([value isEqualToString:@"EF1"]) {
        [self sendWifiNameData:peripheral characteristic:characteristic name:@"" type:PackageEnumEF2];
    } else if([value isEqualToString:@"EF2"]) {
        [self sendWifiNameData:peripheral characteristic:characteristic name:@"94bugaosuni" type:PackageEnumEF3];
    } else if ([value isEqualToString:@"EF3"]) {
        [self sendWifiNameData:peripheral characteristic:characteristic name:@"" type:PackageEnumEF4];
    } else if ([value isEqualToString:@"EF0"]) {
        [self sendWifiNameData:peripheral characteristic:characteristic name:@"EF" type:PackageEnumEF1];
    } else if ([value isEqualToString:@"CODE0\r\n"]) {
        NSLog(@"配网成功");
    } else if ([value isEqualToString:@"CODE1\r\n"]) {
        NSLog(@"配网失败");
    } else {
        NSLog(@"收到其他数据 = %@", value);
    }
}

// 搜索到Characteristic的Descriptors
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //打印出Characteristic和他的Descriptors
    NSLog(@"characteristic uuid:%@ ,  thread = %@", characteristic.UUID, [NSThread currentThread]);
    for (CBDescriptor * d in characteristic.descriptors) {
        NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

//获取到Descriptors的值
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
//    //打印出DescriptorsUUID 和value
//    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
//    NSLog(@" 获取到Descriptors的值 === characteristic uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
//}

// 写入数据的回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"写入数据失败");
        return;
    }
    NSLog(@"写入成功");
}

//- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (!error) {
//        NSLog(@"NotificationState = %@", characteristic.value);
////        [peripheral readValueForCharacteristic:characteristic];
//    } else {
//        NSLog(@"error = %@", error.localizedDescription);
//    }
//}

#pragma mark - 写入数据
- (void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    //只有 characteristic.properties 有write的权限才可以写
    if(characteristic.properties & CBCharacteristicPropertyWrite) {
        // 最好一个type参数可以为CBCharacteristicWriteWithResponse或type:CBCharacteristicWriteWithResponse,区别是是否会有反馈
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"开始写入数据");
        return;
    }
    NSLog(@"该字段不可写");
}


#pragma mark - 组织数据
- (void)sendWifiNameData:(CBPeripheral *)peripheral
          characteristic:(CBCharacteristic *)characteristic name:(NSString *)name type:(PackageEnum)type{
    Byte dataByte[KpackageDataLength];
    for(int i = 0;i < KpackageDataLength; i++) {
        dataByte[i] = 0xff;
    }
    dataByte[0] = type;
    if (name.length == 0) {
        dataByte[1] = 0xff;
        for (int i = 0; i < 16; i ++) {
            dataByte[i + 2] = 0xff;
        }
    } else {
        NSData * nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger length = nameData.length;
        Byte * nameByte = (Byte *)[nameData bytes];
        int nameLength = [self getDataLength:length];
        if (nameLength != 0) {
            dataByte[1] = nameLength;
        }
        for (int i = 0; i<length; i ++) {
            dataByte[i + 2] = nameByte[i];
        }
    }
    dataByte[18] = 0x0D;
    dataByte[19] = 0X0A;
    NSData * sendData = [[NSData alloc] initWithBytes:dataByte length:KpackageDataLength];
    [self writeCharacteristic:peripheral characteristic:characteristic value:sendData];
}


- (int)getDataLength:(NSUInteger)length {
    // 0xFF,0x10, 0x20,0x30,0x40,0x50,0x60,0x70,0x80,0x90,0xA0,0xB0,0xC0,0xD0,0xE0,0xF0,0xF1
    switch (length) {
        case 0:
            return 0xff;
            break;
        case 1:
            return 0x10;
            break;
        case 2:
            return 0x20;
            break;
        case 3:
            return 0x30;
            break;
        case 4:
            return 0x40;
            break;
        case 5:
            return 0x50;
            break;
        case 6:
            return 0x60;
            break;
        case 7:
            return 0x70;
            break;
        case 8:
            return 0x80;
            break;
        case 9:
            return 0x90;
            break;
        case 10:
            return 0xa0;
            break;
        case 11:
            return 0xb0;
            break;
        case 12:
            return 0xc0;
            break;
        case 13:
            return 0xd0;
            break;
        case 14:
            return 0xd0;
            break;
        case 15:
            return 0xf0;
            break;
        case 16:
            return 0xf1;
            break;
        default:
            return 0;
            break;
    }
}
@end
