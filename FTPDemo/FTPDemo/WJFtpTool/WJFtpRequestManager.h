//
//  WJFtpRequestManager.h
//  WJFtpRequest
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJFtpRequestManagerProtocol.h"


typedef void(^ProgressBlock)(NSInteger currentSize, NSInteger totleSize);
typedef void(^SuccessBlock)(NSString * identifier);
typedef void(^FailBlock)(NSString * identifier, NSString * errorMessage);

@interface WJFtpRequestManager : NSObject

@property(nonatomic, copy) NSString * username;
@property(nonatomic, copy) NSString * password;
@property(nonatomic, copy) NSString * serverIP;
@property(nonatomic, assign) int serverPort;
@property(nonatomic, weak) id<WJFtpRequestManagerDelegate> delegate;


+ (instancetype)shareInstance;

- (void)addDownloadFileWithRelativePath:(NSString *)filePath
                         toLocalPath:(NSString *)localPath
                          identifier:(NSString *)identifier
                               fileSize:(NSInteger)fileSize;

- (void)addUploadFileWithRelativePath:(NSString *)filePath
                            toLocalPath:(NSString *)localPath
                               identifier:(NSString *)identifier;

- (void)createResourceToRemoteRelativeFolder:(NSString *)path identifier:(NSString *)identifier;

- (void)showResourceListRemoteRelativePath:(NSString *)remothPath identifier:(NSString *)identifier;


- (void)stopRequestWithIdentifier:(NSString *)identifier;

- (void)stopAllRequest;
@end


