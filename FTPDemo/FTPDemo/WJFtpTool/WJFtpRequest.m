//
//  WJFtpRequest.m
//  WJFtpRequest
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import "WJFtpRequest.h"
#import "WJTools.h"

typedef NS_ENUM(NSInteger, RequestStatus) {
    RequestStatus_Default,
    RequestStatus_ShowResourceList,
    RequestStatus_DownLoadFile,
    RequestStatus_UpLoadFile,
    RequestStatus_CreateResource,
    RequestStatus_DestoryResource
};

@interface WJFtpRequest ()<NSStreamDelegate>
{
    NSInteger _finishedSize;
    NSInteger _totalSize;
    
    NSString *_ftpUserName;
    NSString *_ftpUserPassword;
    NSString *_ftpServerIp;
    UInt16 _ftpPort;
    
    NSString *_dataServerIp;
    UInt16 _dataPort;
    
    progressAction _progressBlock;
    successAction _sucessBlock;
    failAction _failBlock;
    
    successAction _listSucessBlock;
    failAction _listFailBlock;
    
    NSInteger _commondCount;
    dispatch_source_t _timer;
    
    int _currentThreadIndex;
}
// 命令控制流
@property (nonatomic, strong) NSInputStream * inputStream;
@property (nonatomic, strong) NSOutputStream * outputStream;
// 数据控制流
@property (nonatomic, strong) NSInputStream * dataInputStream;
@property (nonatomic, strong) NSOutputStream * dataOutputStream;

@property (nonatomic, strong) NSString * remotePath;
@property (nonatomic, strong) NSString * localPath;

@property (nonatomic, assign) RequestType requestType;
@property (nonatomic, assign) RequestStatus requestStatus;

@property (nonatomic, strong, readwrite) NSMutableData * listData;
@property (nonatomic, strong, readwrite) NSMutableArray * listEntries;

@property (nonatomic, assign) BOOL isDownLoad;

// 单例线程数组 解决sockets阻塞问题
@property (nonatomic, strong) NSMutableArray * spareThreadArray;

@end

static NSInteger const DEFAULT_BUFFER_SIZE = 1024;
static NSInteger const DOWNLOAD_BUFFER_SIZE = 32768;
static NSInteger const UPLOAD_BUFFER_SIZE = 32768;

@implementation WJFtpRequest

#pragma mark - FTPClient Method

- (instancetype)initFTPClientWithUserName:(NSString *)userName
                             userPassword:(NSString *)userPassword
                                 serverIp:(NSString *)serverIp
                               serverHost:(UInt16)serverHost
{
    if (self = [super init]) {
        
        [self setRequestStatus:RequestStatus_Default];
        
        _ftpUserName = userName;
        _ftpUserPassword = userPassword;
        _ftpServerIp = serverIp;
        _ftpPort = serverHost;
        
        _finishedSize = 0;
        _totalSize = 0;
        
        _currentThreadIndex = 0;
    }
    return self;
}

- (instancetype)initFTPClientWithUserName:(NSString *)userName
                             userPassword:(NSString *)userPassword
                                 serverIp:(NSString *)serverIp
                               serverHost:(UInt16)serverHost
                               identifier:(NSString *)identifier {
    WJFtpRequest * request = [self initFTPClientWithUserName:userName userPassword:userPassword serverIp:serverIp serverHost:serverHost];
    request.identifier = identifier;
    return request;
}

- (void)connectFTPServer {
    [self setRequestStatus:RequestStatus_Default];
    [self openFTPNetworkCommunication];
}

- (void)disconnectFTPServer {
    
    _progressBlock = nil;
    _sucessBlock = nil;
    _failBlock = nil;
    
    _listSucessBlock = nil;
    _listFailBlock = nil;
    
    _totalSize = 0;
    _finishedSize = 0;
    
    self.isDownLoad = NO;
    [self closeFTPNetworkCommunication];
}

// 根据请求方式，打开对应的数据通道
- (void)openFTPDataCommnunication {
    
    switch (self.requestType) {
        case RequestType_DownLoadFile:
            [self downloadRequest];
            break;
        case RequestType_UpLoadFile:
            [self uploadRequest];
            break;
        case RequestType_CreateResource:
            [self createResource];
            break;
        case RequestType_ShowResourceList:
            [self showResourceList];
            break;
        default:
            break;
    }
}

// 创建目录
- (void)createResource
{
    self.requestStatus = RequestStatus_CreateResource;
    [self sendCommand:@"CWD /"];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventNone:
            WJLog(@"stream - 未知的流");
            break;
        case NSStreamEventOpenCompleted:
            WJLog(@"stream - 打开完成");
            break;
        case NSStreamEventHasBytesAvailable:
            WJLog(@"stream - HasBytesAvailable - 接手数据");
            [self handleHasBytesAvailableEventStream:aStream];
            break;
        case NSStreamEventHasSpaceAvailable:
            WJLog(@"stream - HasSpaceAvailable - 发送数据");
            [self handleHasBytesAvailableEventStream:aStream];
            break;
        case NSStreamEventErrorOccurred:
            WJLog(@"stream - 流错误");
            [self handleErrorOccurredStream:aStream];
            break;
        case NSStreamEventEndEncountered:
            WJLog(@"stream - 流关闭");
            break;
        default:
            break;
    }
}

// 处理数据流
- (void)handleHasBytesAvailableEventStream:(NSStream *)stream
{
    switch (self.requestStatus) {
        case RequestStatus_Default:
        RequestStatus_CreateResource:
            [self handleDefauleRequestStream:stream];
            break;
        case RequestStatus_DownLoadFile:
            [self handleDownLoadFileRequestStream:stream];
            break;
        case RequestStatus_UpLoadFile:
            [self handleUpLoadFileRequestStream:stream];
            break;
        case RequestStatus_ShowResourceList:
            [self handleShowResourceListRequestStream:stream];
            break;
        default:
            [self handleDefauleRequestStream:stream];
            break;
    }
}

// 处理错误问题
- (void)handleErrorOccurredStream:(NSStream *)stream
{
    WJLog(@"处理错误流");
    switch (self.requestStatus) {
        case RequestStatus_CreateResource:
            if (_failBlock) {
                [self stopReceiveSucess:NO info:@"创建目录失败"];
            }
            break;
        case RequestStatus_DownLoadFile:
            if (_failBlock) {
                [self stopReceiveSucess:NO info:@"下载文件失败"];
            }
            break;
        case RequestStatus_UpLoadFile:
            if (_failBlock) {
                [self stopReceiveSucess:NO info:@"上传文件失败"];
            }
            break;
        default:
            [self handleErrorStreamCommond];
            break;
    }
}

#pragma mark - 处理发送命令流过程中的异常（阻塞、流关闭等）
- (void)handleErrorStreamCommond {
    WJLog(@"handleErrorStreamCommond _currentThreadIndex = %d", _currentThreadIndex);
    //  [self sendCommand:@"QUIT"];
    [self closeFTPDataCommnunication];
    [self closeNSStream:self.inputStream];
    [self closeNSStream:self.outputStream];
    [[NSNotificationCenter defaultCenter] postNotificationName:WJFtpRequestCommandStreamErrorNotification object:@{@"identifier": self.identifier}];
}

// 处理消息流
- (void)handleDefauleRequestStream:(NSStream *)stream
{
    WJLog(@"开始处理 Defaule - Stream");
    if (stream == self.inputStream) {
        uint8_t buffer[DEFAULT_BUFFER_SIZE];
        long len;
        while ([self.inputStream hasBytesAvailable]) {
            len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                if (output) {
                    [self parseResponseMessage:output];
                }
            } else if (len == -1) {
                if (self.requestType == RequestType_CreateResource) {
                    _listFailBlock(@"创建目录失败");
                    [self disconnectFTPServer];
                } else {
                    [self stopReceiveSucess:NO info:@"读取消息数据出错"];
                }
            } else {
                break;
            }
        }
    }
}

#pragma mark - DownLoadFile
// 下载文件
- (void)downloadRequest
{
    CFReadStreamRef readStream;
    // 读取文件
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_dataServerIp, _dataPort, &readStream, nil);
    
    self.dataInputStream = (__bridge_transfer NSInputStream *)readStream;
    self.dataInputStream.delegate = self;
    [self addStreamToThread:self.dataInputStream];
    [self.dataInputStream open];
    
    self.requestStatus = RequestStatus_DownLoadFile;
    self.dataOutputStream = [NSOutputStream outputStreamToFileAtPath:self.localPath append:NO];
    [self.dataOutputStream open];
    [self sendCmdRETR];
}

// 处理下载流
- (void)handleDownLoadFileRequestStream:(NSStream *)stream
{
    WJLog(@"开始处理 Download - Stream");
    NSInteger bytesRead;
    uint8_t buffer[DOWNLOAD_BUFFER_SIZE];
    bytesRead = [self.dataInputStream read:buffer maxLength:sizeof(buffer)];
    
    if (bytesRead == -1) {
        [self stopReceiveSucess:NO info:@"读取网络数据出错"];
    } else if (bytesRead == 0) {
        [self stopReceiveSucess:YES info:self.localPath];
    } else {
        NSInteger   bytesWritten;//实际写入数据
        NSInteger   bytesWrittenSoFar;//当前写入的位置
        
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [self.dataOutputStream write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
            if (bytesWritten == -1) {
                [self stopReceiveSucess:NO info:@"文件下载出错"];
                WJLog(@"处理 下载流 错误");
                break;
            } else  if (bytesWritten > 0) {
                bytesWrittenSoFar += bytesWritten;
                _finishedSize += bytesWritten;
                _progressBlock(_totalSize,_finishedSize);
            } else {
                break;
            }
        } while (bytesRead - bytesWrittenSoFar > 0);
    }
}

#pragma mark - upLoadFile

// 上传文件
- (void)uploadRequest
{
    CFWriteStreamRef writeStream;
    // 写文件
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_dataServerIp, _dataPort, nil, &writeStream);
    self.dataOutputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.dataOutputStream open];
    self.requestStatus = RequestStatus_UpLoadFile;
    self.dataInputStream = [NSInputStream inputStreamWithFileAtPath:self.localPath];
    [self addStreamToThread:self.dataInputStream];
    self.dataInputStream.delegate = self;
    [self.dataInputStream open];
    [self sendCmdSTOR];
}

// 处理上传文件流
- (void)handleUpLoadFileRequestStream:(NSStream *)stream
{
    WJLog(@"开始处理 upload - Stream");
    NSInteger bytesRead;
    uint8_t buffer[UPLOAD_BUFFER_SIZE];
    bytesRead = [self.dataInputStream read:buffer maxLength:sizeof(buffer)];
    WJLog(@"_totalSize = %ld", (long)_totalSize);
    WJLog(@"bytesRead = %ld", (long)bytesRead);
    if (bytesRead == -1) {
        [self stopReceiveSucess:NO info:@"读取本地文件出错"];
    } else if (bytesRead == 0) {
        [NSThread sleepForTimeInterval:1];
        [self stopReceiveSucess:YES info:self.remotePath];
    } else {
        NSInteger   bytesWritten;//实际写入数据
        NSInteger   bytesWrittenSoFar;//当前数据写入位置
        
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [self.dataOutputStream write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
            
            WJLog(@"bytesWritten = %ld", (long)bytesWritten);
            WJLog(@"bytesWrittenSoFar = %ld", (long)bytesWrittenSoFar);
            
            if (bytesWritten == -1) {
                [self stopReceiveSucess:NO info:@"文件上传出错"];
                break;
            } else if (bytesWritten > 0){
                bytesWrittenSoFar += bytesWritten;
                _finishedSize += bytesWritten;
                WJLog(@"bytesWritten = %ld", (long)bytesWritten);
                WJLog(@"bytesWrittenSoFar = %ld", (long)bytesWrittenSoFar);
                _progressBlock(_totalSize,_finishedSize);
            } else {
                break;
            }
        } while (bytesWrittenSoFar != bytesRead);
    }
}

#pragma mark - showList
// 展示列表
- (void)showResourceList
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    // 读取文件
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)_dataServerIp, _dataPort, &readStream, &writeStream);
    
    self.dataInputStream = (__bridge_transfer NSInputStream *)readStream;
    self.dataInputStream.delegate = self;
    [self addStreamToThread:self.dataInputStream];
    [self.dataInputStream open];
    
    self.dataOutputStream = (__bridge_transfer NSOutputStream *)writeStream;
    self.dataOutputStream.delegate = self;
    [self addStreamToThread:self.dataOutputStream];
    [self.dataOutputStream open];
    
    self.requestStatus = RequestStatus_ShowResourceList;
    [self sendCmdLIST];
}

// 处理列表流
- (void)handleShowResourceListRequestStream:(NSStream *)stream
{
    WJLog(@"开始处理 showlist - Stream");
    NSInteger       bytesRead;
    uint8_t         buffer[32768];
    
    bytesRead = [self.dataInputStream read:buffer maxLength:sizeof(buffer)];
    WJLog(@"开始处理 showlist = %ld", (long)bytesRead);
    if (bytesRead < 0) {
        WJLog(@"读取文件列表出错或该文件不存在");
        _listFailBlock(@"获取文件列表出错");
        [self disconnectFTPServer];
    } else if (bytesRead == 0) {
        [self parseListData];
    } else {
        [self.listData appendBytes:buffer length:(NSUInteger) bytesRead];
    }
}

- (void)parseListData
{
    NSMutableArray *    newEntries;
    NSUInteger          offset;
    newEntries = [NSMutableArray array];
    offset = 0;
    do {
        CFIndex         bytesConsumed;
        CFDictionaryRef thisEntry;
        thisEntry = NULL;
        bytesConsumed = CFFTPCreateParsedResourceListing(NULL, &((const uint8_t *) self.listData.bytes)[offset], (CFIndex) ([self.listData length] - offset), &thisEntry);
        
        if (bytesConsumed > 0) {
            if (thisEntry != NULL) {
                NSDictionary *  entryToAdd;
                entryToAdd = [self entryByReencodingNameInEntry:(__bridge NSDictionary *) thisEntry encoding:NSUTF8StringEncoding];
                [newEntries addObject:entryToAdd];
            }
            offset += (NSUInteger) bytesConsumed;
        }
        if (thisEntry != NULL) {
            CFRelease(thisEntry);
        }
        if (bytesConsumed == 0) {
            break;
        } else if (bytesConsumed < 0) {
            break;
        }
    } while (YES);
    
    if ([newEntries count] != 0) {
        [self addListEntries:newEntries];
    } else {
        WJLog(@"newEntries = %@", newEntries);
        _listFailBlock(@"该目录或文件不存在");
        [self closeFTPNetworkCommunication];
        return;
    }
    if (offset != 0) {
        [self.listData replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
    }
}

- (NSDictionary *)entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
{
    NSDictionary *  result;
    NSString *      name;
    NSData *        nameData;
    NSString *      newName;
    newName = nil;
    name = [entry objectForKey:(id) kCFFTPResourceName];
    if (name != nil) {
        nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
        if (nameData != nil) {
            newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
        }
    }
    if (newName == nil) {
        result = (NSDictionary *) entry;
    } else {
        NSMutableDictionary *   newEntry;
        newEntry = [entry mutableCopy];
        [newEntry setObject:newName forKey:(id) kCFFTPResourceName];
        result = newEntry;
    }
    return result;
}

- (void)addListEntries:(NSArray *)newEntries
{
    [self.listEntries addObjectsFromArray:newEntries];
    if (_listSucessBlock) {
        _failBlock = nil;
        _listSucessBlock([NSArray class],self.listEntries);
    }
    
    if (!self.isDownLoad) {
        [self disconnectFTPServer];
    }
}

// 终止连接，并且返回状态，是否成功
- (void)stopReceiveSucess:(BOOL)sucess info:(NSString *)info
{
    WJLog(@"关闭连接");
    _listSucessBlock = nil;
    _listFailBlock = nil;
    
    _totalSize = 0;
    _finishedSize = 0;
    
    self.isDownLoad = NO;
    [self closeFTPNetworkCommunication];
    
    _progressBlock = nil;
    if (!sucess) {
        if (_failBlock) {
            _failBlock(info);
        }
    } else {
        if (_sucessBlock) {
            _sucessBlock([NSString class],info);
        }
    }
}

#pragma mark - FTPRequest

- (void)downloadFileWithRelativePath:(NSString *)filePath
                         toLocalPath:(NSString *)localPath
                            progress:(progressAction)progress
                              sucess:(successAction)sucess
                                fail:(failAction)fail
{
    self.remotePath = filePath;
    self.localPath = localPath;
    self.isDownLoad = YES;
    _totalSize = self.downLaodFileSize > 0 ? self.downLaodFileSize : 0;
    
    //  if (_currentThreadIndex == 0) { // 模拟下载失败
    //    _currentThreadIndex ++;
    //    [self downLoadFile];
    //    return;
    //  }
    
    //  _progressBlock = progress;
    //  _sucessBlock = sucess;
    //  _failBlock = fail;
    //
    //  self.requestType = RequestType_DownLoadFile;
    //  [self connectFTPServer];
    
    WJLog(@"开始下载任务");
    __weak typeof(self) weakSelf = self;
    // 检查服务器是否存在
    [self showResourceListRemoteRelativePath:filePath sucess:^(__unsafe_unretained Class resultClass, id result) {
        WJLog(@"开始下载任务 - 检查服务器文件成功");
        // 获取FTP文件大小，如果F服务器没有返回数据
        if (_totalSize == 0) {
            NSDictionary *dict =  [result firstObject];
            NSString * fileSize = [dict objectForKey:(id)kCFFTPResourceSize];
            _totalSize = fileSize.integerValue;
        }
        
        _remotePath = filePath;
        _localPath = localPath;
        
        _progressBlock = progress;
        _sucessBlock = sucess;
        _failBlock = fail;
        
        weakSelf.requestType = RequestType_DownLoadFile;
        [weakSelf connectFTPServer];
        
    } fail:^(NSString *errorDescription) {
        WJLog(@"开始下载任务 - 检查服务器文件失败");
        fail(errorDescription);
    }];
}

- (void)uploadFileToRemoteRelativePath:(NSString *)remotefilePath
                         withLocalPath:(NSString *)localPath
                              progress:(progressAction)progress
                                sucess:(successAction)sucess
                                  fail:(failAction)fail
{
    
    NSString *floder = [remotefilePath stringByDeletingLastPathComponent];
    
    NSData* data = [NSData dataWithContentsOfFile:localPath];
    _totalSize = data.length;
    
    if (floder.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self createResourceToRemoteRelativeFolder:floder sucess:^(__unsafe_unretained Class resultClass, id result) {
            
            self->_progressBlock = progress;
            self->_sucessBlock = sucess;
            self->_failBlock = fail;
            
            [weakSelf setRequestType:RequestType_UpLoadFile];
            weakSelf.remotePath = remotefilePath;
            weakSelf.localPath = localPath;
            [weakSelf uploadRequest];
            
        } fail:^(NSString *errorDescription) {
            WJLog(@"创建文件夹失败 = %@", errorDescription);
            fail(errorDescription);
        }];
    } else {
        
        _progressBlock = progress;
        _sucessBlock = sucess;
        _failBlock = fail;
        
        self.remotePath = remotefilePath;
        self.localPath = localPath;
        
        [self setRequestType:RequestType_UpLoadFile];
        [self connectFTPServer];
    }
}

- (void)createResourceToRemoteRelativeFolder:(NSString *)remoteFolder
                                      sucess:(successAction)sucess
                                        fail:(failAction)fail
{
    _listSucessBlock = sucess;
    _listFailBlock = fail;
    
    self.remotePath = remoteFolder;
    [self setRequestType:RequestType_CreateResource];
    [self connectFTPServer];
}

- (void)showResourceListRemoteRelativePath:(NSString *)remotefilePath
                                    sucess:(successAction)sucess
                                      fail:(failAction)fail
{
    _listSucessBlock = sucess;
    _listFailBlock = fail;
    
    self.listData = [NSMutableData data];
    self.listEntries = [NSMutableArray array];
    
    self.remotePath = remotefilePath;
    [self setRequestType:RequestType_ShowResourceList];
    [self connectFTPServer];
}

#pragma mark - FTPConnection

// 建立服务器连接
- (void)openFTPNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    WJLog(@"开始建立服务器链接");
    CFStreamCreatePairWithSocketToHost(NULL,(__bridge CFStringRef)_ftpServerIp, _ftpPort, &readStream, &writeStream);
    
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    [self addStreamToThread:self.inputStream];
    [self addStreamToThread:self.outputStream];
    [self.inputStream open];
    [self.outputStream open];
    WJLog(@"开始建立服务器链接 - open");
}

- (void)closeFTPNetworkCommunication {
    WJLog(@"closeFTPNetworkCommunication");
    [self sendCommand:@"QUIT"];
    [self closeFTPDataCommnunication];
    [self closeNSStream:self.inputStream];
    [self closeNSStream:self.outputStream];
}

- (void)closeFTPDataCommnunication {
    [self closeNSStream:self.dataInputStream];
    [self closeNSStream:self.dataOutputStream];
}

- (void)closeNSStream:(NSStream *)aStream {
    if (aStream.streamStatus != NSStreamStatusClosed) {
        [aStream close];
        [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        aStream.delegate = nil;
        aStream = nil;
        WJLog(@"closeNSStream");
    }
}

#pragma mark - thread management
+ (NSThread *)networkThread {
    static NSThread *networkThread = nil;
    static dispatch_once_t multiThreadSingleton;
    dispatch_once(&multiThreadSingleton, ^{
        networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadMain) object:nil];
        [networkThread start];
    });
    return networkThread;
}

// 备用线程解决阻塞
+ (NSThread *)networkThreadSpare {
    static NSThread * networkThreadSpare = nil;
    static dispatch_once_t multiThreadSingletonSpare;
    dispatch_once(&multiThreadSingletonSpare, ^{
        networkThreadSpare = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadMain) object:nil];
        [networkThreadSpare start];
    });
    return networkThreadSpare;
}

+ (void)networkThreadMain {
    do {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    } while(YES);
}

- (void)scheduleInCurrentThread:(NSStream *)senderStream {
    [senderStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode: NSRunLoopCommonModes];
}

#pragma mark - FTPCommand

// 用户名
- (void)sendUserName {
    [self startTimer];
    [self sendCommand:[NSString stringWithFormat:@"USER %@",_ftpUserName]];
}

// 密码
- (void)sendUserPassword {
    [self stopTimer];
    [self sendCommand:[NSString stringWithFormat:@"PASS %@",_ftpUserPassword]];
}

// 创建目录
- (void)sendCmdMKD {
    [self sendCommand:[NSString stringWithFormat:@"MKD %@",self.remotePath]];
}

// 上传
- (void)sendCmdSTOR {
    [self sendCommand:[NSString stringWithFormat:@"STOR %@",self.remotePath]];
}

// 下载
- (void)sendCmdRETR {
    [self sendCommand:[NSString stringWithFormat:@"RETR %@",self.remotePath]];
}

- (void)sendCmdLIST {
    [self sendCommand:[NSString stringWithFormat:@"LIST %@",self.remotePath]];
}

// 切换目录
- (void)sendCmdCWD {
    [self sendCommand:@"CWD /"];
}

// 退出
- (void)sendCmdQUIT {
    [self sendCommand:@"QUIT"];
}

// 被动模式
- (void)sendCmdPASV {
    [self sendCommand:@"PASV"];
}

- (void)sendCommand:(NSString *)cmd {
    if (self.outputStream) {
        WJLog(@"sendCommand = %@", cmd);
        NSString *cmdToSend = [NSString stringWithFormat:@"%@\r\n", cmd];
        NSData *data = [[NSData alloc] initWithData:[cmdToSend dataUsingEncoding:NSUTF8StringEncoding]];
        [self.outputStream write:[data bytes] maxLength:[data length]];
    } else {
        WJLog(@"输出流不存在，无法发送指令");
    }
}

#pragma mark - FTPDataCmdCommunication
- (void)parseResponseMessage:(NSString *)stringData {
    NSString *code = [stringData substringToIndex:3];
    int responseCode = [code intValue];
    switch (responseCode) {
        case 150:
            //打开连接
            WJLog(@"打开连接");
            break;
        case 200:
            //成功
            [self sendCmdPASV];
            break;
            
        case 220:
            //服务就绪 需要输入账号
            WJLog(@"服务就绪 需要输入账号");
            [self sendUserName];
            break;
            
        case 226:
            //结束数据连接
            WJLog(@"结束链接");
            break;
            
        case 227:
            //进入被动模式（IP 地址、ID 端口）
            WJLog(@"进入被动模式");
            [self acceptDataStreamConfiguration:stringData];
            break;
            
        case 230:
            //登录因特网
            [self sendCmdPASV];
            break;
            
        case 250:
            //文件行为完成 列出文件目录
            //如果当前状态是创建目录，发送创建目录消息
            if (self.requestStatus == RequestStatus_CreateResource) {
                [self sendCmdMKD];
            }
            break;
            
        case 257:
            //路径名建立 创建目录成功
            if (self.requestStatus == RequestStatus_CreateResource) {
                if (_listSucessBlock) {
                    _listSucessBlock([NSString class], [self remotePath]);
                }
            }
            break;
        case 331:
            //要求密码
            WJLog(@"输入密码");
            [self sendUserPassword];
            break;
            
        case 530:
            //未登录网络 用户名或密码错误
            WJLog(@"未登录网络 用户名或密码错误 - user = %@ psd = %@", _ftpUserName, _ftpUserPassword);
            [self handleErrorStreamCommond];
            break;
        case 550:
            // 权限 项目是 文件夹已经存在
            WJLog(@"权限拒绝 - 文件夹已经存在");
            if (self.requestStatus == RequestStatus_CreateResource) {
                if (_listSucessBlock) {
                    _listSucessBlock([NSString class], [self remotePath]);
                }
            }
            break;
        default:
            WJLog(@"parseResponseMessage - responseCode = %d", responseCode);
            break;
    }
}

- (void)acceptDataStreamConfiguration:(NSString *)serverResponse {
    NSString *pattern=  @"([-\\d]+),([-\\d]+),([-\\d]+),([-\\d]+),([-\\d]+),([-\\d]+)";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:serverResponse options:0 range:NSMakeRange(0, [serverResponse length])];
    
    _dataServerIp = [NSString stringWithFormat:@"%@.%@.%@.%@",
                     [serverResponse substringWithRange:[match rangeAtIndex:1]],
                     [serverResponse substringWithRange:[match rangeAtIndex:2]],
                     [serverResponse substringWithRange:[match rangeAtIndex:3]],
                     [serverResponse substringWithRange:[match rangeAtIndex:4]]];
    _dataPort = ([[serverResponse substringWithRange:[match rangeAtIndex:5]] intValue] * 256) + [[serverResponse substringWithRange:[match rangeAtIndex:6]] intValue];
    
    WJLog(@"_dataServerIp = %@, _dataPort = %d", _dataServerIp, _dataPort);
    if (_dataServerIp != _ftpServerIp) {
        _dataServerIp = _ftpServerIp;
    }
    [self openFTPDataCommnunication];
}

- (void)addStreamToThread:(NSStream *)object {
    WJLog(@"addStreamToThread index = %d", _currentThreadIndex);
    NSThread * currentThread = self.spareThreadArray[_currentThreadIndex];
    [self performSelector:@selector(scheduleInCurrentThread:) onThread:currentThread withObject:object waitUntilDone:YES];
}

#pragma mark - time 处理命令流阻塞情况
- (void)startTimer {
    if (_timer == nil) {
        _commondCount = 0;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 5 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            [self handleTimerSource];
        });
        dispatch_resume(_timer);
    } else {
        dispatch_resume(_timer);
    }
}

- (void)stopTimer {
    if (_timer != nil) {
        dispatch_suspend(_timer);
        _commondCount = 0;
    }
}

- (void)handleTimerSource {
    _commondCount++;
    WJLog(@"_commondCount = %ld", (long)_commondCount);
    if (_commondCount >= 2) {
        [self stopTimer];
        [self handleThreadIndex];
        [self handleErrorStreamCommond];
    }
}

- (void)handleThreadIndex {
    _currentThreadIndex ++;
    if (_currentThreadIndex > self.spareThreadArray.count - 1) {
        _currentThreadIndex = 0;
    }
}

// 这种处理阻塞(存在了两个单例线程并不合理)
- (NSMutableArray *)spareThreadArray {
    if (_spareThreadArray == nil) {
        _spareThreadArray = [NSMutableArray array];
        [_spareThreadArray addObject:[[self class] networkThread]];
        [_spareThreadArray addObject:[[self class] networkThreadSpare]];
    }
    return _spareThreadArray;
}

//- (NSInteger)downLaodFileSize {
//    if (_downLaodFileSize <= 0) {
//        NSAssert(_downLaodFileSize > 0, @"downLaodFileSize is not <= 0");
//    }
//    return _downLaodFileSize;
//}

- (void)dealloc {
    WJLog(@"dealloc - %@", NSStringFromClass([self class]));
}

#pragma mark - test
- (void)downLoadFile {
    [[NSNotificationCenter defaultCenter] postNotificationName:WJFtpRequestCommandStreamErrorNotification object:@{@"identifier": self.identifier}];
}
@end
