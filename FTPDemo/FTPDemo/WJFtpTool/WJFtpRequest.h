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
/**
 *  构造函数初始化
 *
 *  @param userName     ftp服务器用户名
 *  @param userPassword ftp服务器密码
 *  @param serverIp     ftp服务器ip
 *  @param serverHost   ftp服务器端口
 *
 *  @return 请求实例
 */
- (instancetype )initFTPClientWithUserName:(NSString *)userName
                              userPassword:(NSString *)userPassword
                                  serverIp:(NSString *)serverIp
                                serverHost:(UInt16)serverHost;

- (instancetype )initFTPClientWithUserName:(NSString *)userName
                              userPassword:(NSString *)userPassword
                                  serverIp:(NSString *)serverIp
                                serverHost:(UInt16)serverHost
                                identifier:(NSString *)identifier;

/**
 *  从服务器下载文件
 *
 *  @param filePath  远程文件的相对路径，当前路径为服务器的根目录
 *  @param localPath 下载文件要保存的本地路径
 *  @param progress  下载进度
 *  @param sucess    下载成功
 *  @param fail      下载失败
 */
- (void)downloadFileWithRelativePath:(NSString *)filePath
                         toLocalPath:(NSString *)localPath
                            progress:(progressAction)progress
                              sucess:(successAction)sucess
                                fail:(failAction)fail;

/**
 *  上传文件到服务器
 *
 *  @param remotefilePath  远程文件的相对路径，当前路径为服务器的根目录
 *  @param localPath 上传文件的本地路径
 *  @param progress  上传进度
 *  @param sucess    上传成功
 *  @param fail      上传失败
 */
- (void)uploadFileToRemoteRelativePath:(NSString *)remotefilePath
                         withLocalPath:(NSString *)localPath
                              progress:(progressAction)progress
                                sucess:(successAction)sucess
                                  fail:(failAction)fail;

/**
 *  创建目录到服务器
 *
 *  @param remoteFolder  远程文件的相对路径，当前路径为服务器的根目录
 *  @param sucess        创建成功
 *  @param fail          创建失败
 */
- (void)createResourceToRemoteRelativeFolder:(NSString *)remoteFolder
                                      sucess:(successAction)sucess
                                        fail:(failAction)fail;

/**
 *  列出目录详情
 *
 *  @param remotefilePath  远程文件的相对路径，当前路径为服务器的根目录
 *  @param sucess    列出成功
 *  @param fail      列出失败
 */
- (void)showResourceListRemoteRelativePath:(NSString *)remotefilePath
                                    sucess:(successAction)sucess
                                      fail:(failAction)fail;

/// 外界停止上传资源
- (void)stopUploadResource;
@end
