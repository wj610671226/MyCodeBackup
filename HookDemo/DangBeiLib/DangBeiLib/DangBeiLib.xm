// See http://iphonedevwiki.net/index.php/Logos

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

@interface playInfoRes
@property(nonatomic) _Bool isSelected; // @synthesize isSelected=_isSelected;
@property(retain, nonatomic) NSString *videoFormatName; // @synthesize videoFormatName=_videoFormatName;
@property(retain, nonatomic) NSString *playURL; // @synthesize playURL=_playURL;
@property(retain, nonatomic) NSString *videoFormat; // @synthesize videoFormat=_videoFormat;
@end

/**
 
 首页小红包
 
 DBYHomeController
 
 DBYHomeLittleADView
 
 DBYDxMovieLittleRedPacketView
 
 首页大红包
 DBYDxMovieForTheFirstTimeRedPacketView
 
 启动页广告
XHLaunchAd
 
 播放页面   DBYMovieDetailController
 
 暂停广告  DBYPlayPauseADView
 
 播放之前的广告  DBYBeforeOrEndPlayADView
 */
// 启动页广告
%hook XHLaunchAd
+ (id)shareLaunchAd {
    return nil;
}
%end

// 首页小红包
%hook DBYHomeLittleADView
+ (void)showInView:(id)arg1 WithAdModel:(id)arg2 {

}
%end

// 首页大红包
%hook DBYDxMovieForTheFirstTimeRedPacketView
+ (void)show {
    
}
%end

// 播放视频 暂停广告
%hook DBYPlayPauseADView
+ (id)showInPlayerView:(id)arg1 withModel:(id)arg2 {
    return nil;
}
%end

// 播放广告
%hook DBYMovieDetailController
- (void)setupDetailAD {
}
%end


/*
首页小小红包 解决思路
 1、 DBYDxMovieLittleRedPacketView
 
 %hook DBYDxMovieLittleRedPacketView
 // 闪退
 - (id)init {
     return nil;
 }
 %end
 - (void)handlePan:(id)arg1;
 
 2、DBYDxMovieLittleRedPacketView  -> DBYHomeController
 DBYHomeController
 checkLittleAdAndLittleRedPacketHidden 查看汇编代码
 
 3、 DBYDxMovieForTheFirstTimeRedPacketManager
 @interface DBYDxMovieForTheFirstTimeRedPacketManager : NSObject
 {
 }

 + (void)dismissLittileRedpacketInView:(id)arg1;
 + (void)showLittleRedpacketInView:(id)arg1;
 + (void)setup;
 */


%hook DBYDxMovieForTheFirstTimeRedPacketManager
+ (void)showLittleRedpacketInView:(id)arg1 {
    
}
%end




//  ----------默认播放模式------------
/**
 
 播放模式  标清 高清
 DBYVideoTypeView
 
 横屏播放界面
 ZFLandScapeControlView
 
 竖屏播放页面
 ZFPortraitControlView - ZFPlayerPresentView
 
 //播放页面底部  控制 View  ZFPlayerControlView
 
 ZFPlayerPresentView > ZFPlayerControlView  > ZFPortraitControlView、ZFLandScapeControlView
 */

%hook DBYBaseViewController
- (void)setPlayerURLString:(NSString *)arg1 showTitle:(id)arg2 coverURLString:(id)arg3 playInfo:(NSArray *)arg4 withID:(long long)arg5 defaultVideoFormat:(id)arg6 {
//    NSLog(@"DBYBaseViewController - arg1 = %@ - arg1 class = %@ - arg2 = %@ - arg2 class = %@ - arg3 = %@ - arg3 class = %@",arg1,[arg1 class],arg2,[arg2 class],arg3,[arg3 class]);
//    NSLog(@"DBYBaseViewController - arg4 = %@ - arg4 class = %@ - arg5 = %ld - arg6 = %@ - arg6 class = %@",arg4,[arg4 class],arg5,arg6,[arg6 class]);
//    NSLog(@"--------------");
    
//    NSLog(@"DBYBaseViewController - before arg4 = %@",arg4);
//    NSUInteger count = arg4.count;
//    playInfoRes * info = arg4[count - 1];
//    info.isSelected = YES;
    
    NSArray * targetArray = [[arg4 reverseObjectEnumerator] allObjects];
//    NSLog(@"DBYBaseViewController - targetArray = %@",targetArray);
    %orig(arg1, arg2, arg3, targetArray, arg5, arg6);
}
%end
