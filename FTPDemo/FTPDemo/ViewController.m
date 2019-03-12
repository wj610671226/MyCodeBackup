//
//  ViewController.m
//  FTPDemo
//
//  Created by wangjie on 2019/3/12.
//  Copyright © 2019年 wangjie. All rights reserved.
//

#import "ViewController.h"
#import "WJFtpRequestManager.h"
#import "WJTools.h"

@interface ViewController ()<WJFtpRequestManagerDelegate>
@property (nonatomic, strong)WJFtpRequestManager * manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickShowPath:(UIButton *)sender {
    [self.manager showResourceListRemoteRelativePath:@"2018-09-13-1/" identifier:@""];
}

- (IBAction)clickUploadFile:(UIButton *)sender {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"test.png" ofType:nil];
    [self.manager addUploadFileWithRelativePath:@"/2018-09-13-1/test.png" toLocalPath:path identifier:@""];
}

- (IBAction)clickDownFile:(UIButton *)sender {
    NSString * localPath = [NSHomeDirectory() stringByAppendingPathComponent:@"123.png"];
    [self.manager addDownloadFileWithRelativePath:@"/2018-09-13-1/test.png" toLocalPath:localPath identifier:@""];
}


- (WJFtpRequestManager *)manager {
    if (_manager == nil) {
        _manager = [WJFtpRequestManager shareInstance];
        _manager.username = @"username";
        _manager.password = @"password";
        _manager.serverIP = @"serverIP";
        _manager.serverPort = 21;
        _manager.delegate = self;
    }
    return _manager;
}

#pragma mark - FYFtpRequestManagerDelegate
- (void)requestsManagerError:(NSString *)error identifier:(NSString *)identifier {
    WJLog(@"requestsManagerError = %@ identifier = %@", error, identifier);
}

-  (void)requestsManagerDidCompleteCreateDirectory:(NSString *)directory {
    WJLog(@"CreateDirectory = %@", directory);
}

- (void)requestsManagerDidCompleteListing:(NSArray *)listing {
    WJLog(@"requestsManagerDidCompleteListing = %@", listing);
}

- (void)requestsManagerDownloadDidCompleteLocalPath:(NSString *)localPath identifier:(NSString *)identifier {
    WJLog(@"DownloadDidComplete = %@ - %@", identifier, localPath);
    
}

- (void)requestsManagerUploadDidCompleteLocalPath:(NSString *)localPath identifier:(NSString *)identifier {
    WJLog(@"UploadDidCompleteLocalPat = %@", identifier);
}

- (void)requestsManagerProcess:(float)process identifier:(NSString *)identifier {
    WJLog(@"process = %.2f  - identifier = %@", process, identifier);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
