//
//  WJFtpRequestManagerProtocol.h
//  WJFtpRequest
//
//  Created by 30san on 2018/12/13.
//  Copyright © 2018 FY. All rights reserved.
//


@protocol WJFtpRequestManagerDelegate <NSObject>

- (void)requestsManagerDidCompleteListing:(NSArray *)listing;

- (void)requestsManagerDidCompleteCreateDirectory:(NSString *)directory;

- (void)requestsManagerError:(NSString *)error identifier:(NSString *)identifier;

- (void)requestsManagerProcess:(float)process identifier:(NSString *)identifier;

- (void)requestsManagerDownloadDidCompleteLocalPath:(NSString *)localPath identifier:(NSString *)identifier;

- (void)requestsManagerUploadDidCompleteLocalPath:(NSString *)localPath identifier:(NSString *)identifier;

@end
