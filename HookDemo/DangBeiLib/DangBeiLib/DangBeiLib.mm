#line 1 "/Users/wangjie/Desktop/DangBeiLib/DangBeiLib/DangBeiLib.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

@interface playInfoRes
@property(nonatomic) _Bool isSelected; 
@property(retain, nonatomic) NSString *videoFormatName; 
@property(retain, nonatomic) NSString *playURL; 
@property(retain, nonatomic) NSString *videoFormat; 
@end

























#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class DBYHomeLittleADView; @class DBYMovieDetailController; @class DBYDxMovieForTheFirstTimeRedPacketView; @class XHLaunchAd; @class DBYBaseViewController; @class DBYPlayPauseADView; @class DBYDxMovieForTheFirstTimeRedPacketManager; 
static id (*_logos_meta_orig$_ungrouped$XHLaunchAd$shareLaunchAd)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static id _logos_meta_method$_ungrouped$XHLaunchAd$shareLaunchAd(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void (*_logos_meta_orig$_ungrouped$DBYHomeLittleADView$showInView$WithAdModel$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id, id); static void _logos_meta_method$_ungrouped$DBYHomeLittleADView$showInView$WithAdModel$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id, id); static void (*_logos_meta_orig$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView$show)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void _logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView$show(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static id (*_logos_meta_orig$_ungrouped$DBYPlayPauseADView$showInPlayerView$withModel$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id, id); static id _logos_meta_method$_ungrouped$DBYPlayPauseADView$showInPlayerView$withModel$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id, id); static void (*_logos_orig$_ungrouped$DBYMovieDetailController$setupDetailAD)(_LOGOS_SELF_TYPE_NORMAL DBYMovieDetailController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$DBYMovieDetailController$setupDetailAD(_LOGOS_SELF_TYPE_NORMAL DBYMovieDetailController* _LOGOS_SELF_CONST, SEL); static void (*_logos_meta_orig$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager$showLittleRedpacketInView$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id); static void _logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager$showLittleRedpacketInView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$)(_LOGOS_SELF_TYPE_NORMAL DBYBaseViewController* _LOGOS_SELF_CONST, SEL, NSString *, id, id, NSArray *, long long, id); static void _logos_method$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$(_LOGOS_SELF_TYPE_NORMAL DBYBaseViewController* _LOGOS_SELF_CONST, SEL, NSString *, id, id, NSArray *, long long, id); 

#line 39 "/Users/wangjie/Desktop/DangBeiLib/DangBeiLib/DangBeiLib.xm"

static id _logos_meta_method$_ungrouped$XHLaunchAd$shareLaunchAd(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    return nil;
}




static void _logos_meta_method$_ungrouped$DBYHomeLittleADView$showInView$WithAdModel$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {

}




static void _logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView$show(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    
}




static id _logos_meta_method$_ungrouped$DBYPlayPauseADView$showInPlayerView$withModel$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {
    return nil;
}




static void _logos_method$_ungrouped$DBYMovieDetailController$setupDetailAD(_LOGOS_SELF_TYPE_NORMAL DBYMovieDetailController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
}































static void _logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager$showLittleRedpacketInView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    
}























static void _logos_method$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$(_LOGOS_SELF_TYPE_NORMAL DBYBaseViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString * arg1, id arg2, id arg3, NSArray * arg4, long long arg5, id arg6) {



    




    
    NSArray * targetArray = [[arg4 reverseObjectEnumerator] allObjects];

    _logos_orig$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$(self, _cmd, arg1, arg2, arg3, targetArray, arg5, arg6);
}

static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$XHLaunchAd = objc_getClass("XHLaunchAd"); Class _logos_metaclass$_ungrouped$XHLaunchAd = object_getClass(_logos_class$_ungrouped$XHLaunchAd); MSHookMessageEx(_logos_metaclass$_ungrouped$XHLaunchAd, @selector(shareLaunchAd), (IMP)&_logos_meta_method$_ungrouped$XHLaunchAd$shareLaunchAd, (IMP*)&_logos_meta_orig$_ungrouped$XHLaunchAd$shareLaunchAd);Class _logos_class$_ungrouped$DBYHomeLittleADView = objc_getClass("DBYHomeLittleADView"); Class _logos_metaclass$_ungrouped$DBYHomeLittleADView = object_getClass(_logos_class$_ungrouped$DBYHomeLittleADView); MSHookMessageEx(_logos_metaclass$_ungrouped$DBYHomeLittleADView, @selector(showInView:WithAdModel:), (IMP)&_logos_meta_method$_ungrouped$DBYHomeLittleADView$showInView$WithAdModel$, (IMP*)&_logos_meta_orig$_ungrouped$DBYHomeLittleADView$showInView$WithAdModel$);Class _logos_class$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView = objc_getClass("DBYDxMovieForTheFirstTimeRedPacketView"); Class _logos_metaclass$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView = object_getClass(_logos_class$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView); MSHookMessageEx(_logos_metaclass$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView, @selector(show), (IMP)&_logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView$show, (IMP*)&_logos_meta_orig$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketView$show);Class _logos_class$_ungrouped$DBYPlayPauseADView = objc_getClass("DBYPlayPauseADView"); Class _logos_metaclass$_ungrouped$DBYPlayPauseADView = object_getClass(_logos_class$_ungrouped$DBYPlayPauseADView); MSHookMessageEx(_logos_metaclass$_ungrouped$DBYPlayPauseADView, @selector(showInPlayerView:withModel:), (IMP)&_logos_meta_method$_ungrouped$DBYPlayPauseADView$showInPlayerView$withModel$, (IMP*)&_logos_meta_orig$_ungrouped$DBYPlayPauseADView$showInPlayerView$withModel$);Class _logos_class$_ungrouped$DBYMovieDetailController = objc_getClass("DBYMovieDetailController"); MSHookMessageEx(_logos_class$_ungrouped$DBYMovieDetailController, @selector(setupDetailAD), (IMP)&_logos_method$_ungrouped$DBYMovieDetailController$setupDetailAD, (IMP*)&_logos_orig$_ungrouped$DBYMovieDetailController$setupDetailAD);Class _logos_class$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager = objc_getClass("DBYDxMovieForTheFirstTimeRedPacketManager"); Class _logos_metaclass$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager = object_getClass(_logos_class$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager); MSHookMessageEx(_logos_metaclass$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager, @selector(showLittleRedpacketInView:), (IMP)&_logos_meta_method$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager$showLittleRedpacketInView$, (IMP*)&_logos_meta_orig$_ungrouped$DBYDxMovieForTheFirstTimeRedPacketManager$showLittleRedpacketInView$);Class _logos_class$_ungrouped$DBYBaseViewController = objc_getClass("DBYBaseViewController"); MSHookMessageEx(_logos_class$_ungrouped$DBYBaseViewController, @selector(setPlayerURLString:showTitle:coverURLString:playInfo:withID:defaultVideoFormat:), (IMP)&_logos_method$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$, (IMP*)&_logos_orig$_ungrouped$DBYBaseViewController$setPlayerURLString$showTitle$coverURLString$playInfo$withID$defaultVideoFormat$);} }
#line 142 "/Users/wangjie/Desktop/DangBeiLib/DangBeiLib/DangBeiLib.xm"
