//
//  WJFtpRequest.h
//  WJFtpRequest
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const WJFtpRequestCommandStreamErrorNotification = @"WJFtpRequestCommandStreamErrorNotification";

typedef void(^progressAction)(NSInteger totalSize, NSInteger finishedSize);
typedef void(^successAction)(Class resultClass, id result);
typedef void(^failAction)(NSString * errorDescription);

typedef NS_ENUM(NSInteger, RequestType) {
    RequestType_Default,
    RequestType_ShowResourceList,
    RequestType_DownLoadFile,
    RequestType_UpLoadFile,
    RequestType_CreateResource,
    RequestType_DestoryResource
};

@interface WJFtpRequest : NSObject
@property(nonatomic, assign)NSInteger downLaodFileSize;
@property(nonatomic, copy) NSString * identifier;

- (instancetype )initFTPClientWithUserName:(NSString *)userName
                              userPassword:(NSString *)userPassword
                                  serverIp:(NSString *)serverIp
                                serverHost:(UInt16)serverHost;

- (instancetype )initFTPClientWithUserName:(NSString *)userName
                              userPassword:(NSString *)userPassword
                                  serverIp:(NSString *)serverIp
                                serverHost:(UInt16)serverHost
                                identifier:(NSString *)identifier;

- (void)downloadFileWithRelativePath:(NSString *)filePath
                         toLocalPath:(NSString *)localPath
                            progress:(progressAction)progress
                              sucess:(successAction)sucess
                                fail:(failAction)fail;

- (void)uploadFileToRemoteRelativePath:(NSString *)remotefilePath
                         withLocalPath:(NSString *)localPath
                              progress:(progressAction)progress
                                sucess:(successAction)sucess
                                  fail:(failAction)fail;

- (void)createResourceToRemoteRelativeFolder:(NSString *)remoteFolder
                                      sucess:(successAction)sucess
                                        fail:(failAction)fail;

- (void)showResourceListRemoteRelativePath:(NSString *)remotefilePath
                                    sucess:(successAction)sucess
                                      fail:(failAction)fail;
@end
