//
//  FYFtpRequestManager.m
//  FYFtpRequest
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJFtpRequestManager.h"
#import "WJFtpRequest.h"
#import "WJQueue.h"
#import "WJTools.h"

@interface WJFtpRequestManager()
{
    BOOL _isRunning;
}
@property (nonatomic, strong) WJQueue * qrQueue;
@property (nonatomic, strong) WJFtpRequest * currentRequest;
@property (nonatomic, strong) NSMutableArray * failRequesArray; // 失败队列的数据
@end

@implementation WJFtpRequestManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commondStreamError:) name:WJFtpRequestCommandStreamErrorNotification object:nil];
    }
    return self;
}

- (WJQueue *)qrQueue {
    if (_qrQueue == nil) {
        _qrQueue = [[WJQueue alloc] init];
    }
    return _qrQueue;
}


- (void)startProcessingRequests
{
    if (_isRunning == NO) {
        _isRunning = YES;
        [self processNextRequest];
    }
}

- (void)resetState {
    _isRunning = NO;
    [self startProcessingRequests];
}

- (void)processNextRequest
{
    [self checkParams];
    
    NSDictionary * currentRequestInfo = [self.qrQueue dequeue];
    if (currentRequestInfo == nil) {
        WJLog(@"任务完成");
        _isRunning = NO;
        return;
    }
    
    NSInteger type = [currentRequestInfo[@"type"] integerValue];
    NSString * filePath = currentRequestInfo[@"filePath"];
    NSString * identifier = currentRequestInfo[@"identifier"];
    NSString * localPath = currentRequestInfo[@"localPath"];
    
    if (self.currentRequest == nil) {
        self.currentRequest = [[WJFtpRequest alloc] initFTPClientWithUserName:self.username userPassword:self.password serverIp:self.serverIP serverHost:self.serverPort];
    }
    self.currentRequest.identifier = identifier;
    
    WJLog(@"self.currentRequest = %@", self.currentRequest);
    
    switch (type) {
        case RequestType_DownLoadFile:
        {
            [self checkLocalPath:localPath];
            self.currentRequest.downLaodFileSize = [[currentRequestInfo objectForKey:@"fileSize"] integerValue];
            [self.currentRequest downloadFileWithRelativePath:filePath toLocalPath:localPath progress:^(NSInteger totalSize, NSInteger finishedSize) {
                float pross = (finishedSize * 1.0) / (totalSize * 1.0);
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerProcess:identifier:)]) {
                    [self.delegate requestsManagerProcess:pross identifier:identifier];
                }
            } sucess:^(__unsafe_unretained Class resultClass, id result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerDownloadDidCompleteLocalPath:identifier:)]) {
                    [self.delegate requestsManagerDownloadDidCompleteLocalPath:localPath identifier:identifier];
                }
                [self resetState];
            } fail:^(NSString *errorDescription) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerError:identifier:)]) {
                    [self.delegate requestsManagerError:errorDescription identifier:identifier];
                }
                [self resetState];
            }];
        }
            break;
        case RequestType_UpLoadFile:
        {
            [self.currentRequest uploadFileToRemoteRelativePath:filePath withLocalPath:localPath progress:^(NSInteger totalSize, NSInteger finishedSize) {
                float pross = (finishedSize * 1.0) / (totalSize * 1.0);
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerProcess:identifier:)]) {
                    [self.delegate requestsManagerProcess:pross identifier:identifier];
                }
            } sucess:^(__unsafe_unretained Class resultClass, id result) {
                [self checkUploadFileIsExist:filePath localPath:localPath identifier:identifier];
            } fail:^(NSString *errorDescription) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerError:identifier:)]) {
                    [self.delegate requestsManagerError:errorDescription identifier:identifier];
                }
                [self resetState];
            }];
        }
            break;
        case RequestType_ShowResourceList:
        {
            [self.currentRequest showResourceListRemoteRelativePath:filePath sucess:^(__unsafe_unretained Class resultClass, id result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerDidCompleteListing:)]) {
                    [self.delegate requestsManagerDidCompleteListing:result];
                }
                [self resetState];
                
            } fail:^(NSString *errorDescription) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerError:identifier:)]) {
                    [self.delegate requestsManagerError:errorDescription identifier:identifier];
                }
                [self resetState];
            }];
        }
            break;
        case RequestType_CreateResource:
        {
            [self.currentRequest createResourceToRemoteRelativeFolder:filePath sucess:^(__unsafe_unretained Class resultClass, id result) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerDidCompleteCreateDirectory:)]) {
                    [self.delegate requestsManagerDidCompleteCreateDirectory:result];
                }
                [self resetState];
            } fail:^(NSString *errorDescription) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerError:identifier:)]) {
                    [self.delegate requestsManagerError:errorDescription identifier:identifier];
                }
                [self resetState];
            }];
        }
            break;
        default:
            WJLog(@"其他操作");
            break;
    }
}

- (void)addDownloadFileWithRelativePath:(NSString *)filePath
                            toLocalPath:(NSString *)localPath
                             identifier:(NSString *)identifier
                               fileSize:(NSInteger)fileSize {
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    [requestInfo setValue:filePath forKey:@"filePath"];
    [requestInfo setValue:localPath forKey:@"localPath"];
    [requestInfo setValue:@(fileSize) forKey:@"fileSize"];
    [requestInfo setValue:@(RequestType_DownLoadFile) forKey:@"type"];
    [requestInfo setValue:[self getDefultIdentifier:identifier] forKey:@"identifier"];
    
    [self.qrQueue enqueue:requestInfo];
    [self startProcessingRequests];
}


- (void)addDownloadFileWithRelativePath:(NSString *)filePath
                            toLocalPath:(NSString *)localPath
                             identifier:(NSString *)identifier {
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    [requestInfo setValue:filePath forKey:@"filePath"];
    [requestInfo setValue:localPath forKey:@"localPath"];
    [requestInfo setValue:@(0) forKey:@"fileSize"];
    [requestInfo setValue:@(RequestType_DownLoadFile) forKey:@"type"];
    [requestInfo setValue:[self getDefultIdentifier:identifier] forKey:@"identifier"];
    
    [self.qrQueue enqueue:requestInfo];
    [self startProcessingRequests];
}


- (void)addUploadFileWithRelativePath:(NSString *)filePath
                          toLocalPath:(NSString *)localPath
                           identifier:(NSString *)identifier {
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    [requestInfo setValue:filePath forKey:@"filePath"];
    [requestInfo setValue:localPath forKey:@"localPath"];
    [requestInfo setValue:@(RequestType_UpLoadFile) forKey:@"type"];
    [requestInfo setValue:[self getDefultIdentifier:identifier] forKey:@"identifier"];
    
    [self.qrQueue enqueue:requestInfo];
    [self startProcessingRequests];
}

- (void)createResourceToRemoteRelativeFolder:(NSString *)path identifier:(NSString *)identifier {
    if (path.length == 0) {
        WJLog(@"createResourcePath not nil");
        return;
    }
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    [requestInfo setValue:@(RequestType_CreateResource) forKey:@"type"];
    [requestInfo setValue:[self getDefultIdentifier:identifier] forKey:@"identifier"];
    
    [self.qrQueue enqueue:requestInfo];
    [self startProcessingRequests];
}

- (void)showResourceListRemoteRelativePath:(NSString *)remothPath identifier:(NSString *)identifier {
    NSMutableDictionary * requestInfo = [NSMutableDictionary dictionary];
    [requestInfo setValue:remothPath forKey:@"filePath"];
    [requestInfo setValue:@(RequestType_ShowResourceList) forKey:@"type"];
    [requestInfo setValue:[self getDefultIdentifier:identifier] forKey:@"identifier"];
    
    [self.qrQueue enqueue:requestInfo];
    [self startProcessingRequests];
}


- (void)checkUploadFileIsExist:(NSString *)filePath localPath:(NSString *)localPath identifier:(NSString *)identifier {
    WJLog(@"开始检查上传文件是否存在ftp服务器");
    [self.currentRequest showResourceListRemoteRelativePath:filePath sucess:^(__unsafe_unretained Class resultClass, id result) {
        WJLog(@"检查上传文件 result = %@", result);
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerUploadDidCompleteLocalPath:identifier:)]) {
            [self.delegate requestsManagerUploadDidCompleteLocalPath:localPath identifier:identifier];
        }
        [self resetState];
    } fail:^(NSString *errorDescription) {
        WJLog(@"检查上传文件 error = %@", errorDescription);
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestsManagerError:identifier:)]) {
            [self.delegate requestsManagerError:@"上传文件失败" identifier:identifier];
        }
        [self resetState];
    }];
}

- (void)stopRequestWithIdentifier:(NSString *)identifier {
    for (NSMutableDictionary * obj in self.qrQueue.items) {
        if ([obj objectForKey:identifier]) {
            [self.qrQueue.items removeObject:obj];
            break;
        }
    }
}

- (void)stopAllRequest {
    [self.qrQueue clear];
}

#pragma mark - private
- (void)checkLocalPath:(NSString *)loaclPath {
    NSFileManager * flieManger = [NSFileManager defaultManager];
    NSString * dirPath = [loaclPath stringByDeletingLastPathComponent];
    BOOL dirExists = [flieManger fileExistsAtPath:dirPath];
    if (!dirExists) {
        BOOL result = [flieManger createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
        WJLog(@"下载 创建文件夹 = %d, 本地路径 = %@", result, loaclPath);
    }
}

- (NSMutableArray *)failRequesArray {
    if (_failRequesArray == nil) {
        _failRequesArray = [[NSMutableArray alloc] init];
    }
    return _failRequesArray;
}

- (void)checkParams {
    NSAssert(self.username.length > 0, @"username not nil");
    NSAssert(self.password.length > 0, @"username not nil");
    NSAssert(self.serverIP.length > 0, @"username not nil");
    self.serverPort = self.serverPort <= 0 ? 21 : self.serverPort;
}

- (NSString *)getDefultIdentifier:(NSString *)identifier {
    return identifier.length == 0 ? [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] : identifier;
}

static WJFtpRequestManager *_shareInstance;
+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[WJFtpRequestManager alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (void)commondStreamError:(NSNotification *)userInfo {
    WJLog(@"commondStreamError - userInfo = %@", userInfo);
    [self.delegate requestsManagerError:@"操作失败" identifier:[userInfo.object objectForKey:@"identifier"]];
    [self resetState];
}

- (void)dealloc {
    [self.qrQueue clear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    WJLog(@" %@ - dealloc", NSStringFromClass([self class]));
}

@end
