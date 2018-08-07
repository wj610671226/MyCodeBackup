
@interface JYAroundBike : NSObject

@property(copy, nonatomic) NSString *bikeNo; // @synthesize bikeNo=_bikeNo;
@property(copy, nonatomic) NSString *iconType; // @synthesize iconType=_iconType;
@property(retain, nonatomic) NSArray *images; // @synthesize images=_images;
@property(copy, nonatomic) NSString *parkIcon; // @synthesize parkIcon=_parkIcon;
@property(copy, nonatomic) NSString *parkIconPlus; // @synthesize parkIconPlus=_parkIconPlus;
@property(retain, nonatomic) NSString *thumbnail; // @synthesize thumbnail=_thumbnail;

@end

@interface JYNearlyBikeAnnotation : NSObject
@property(retain, nonatomic) JYAroundBike *bike;
@end


@interface JYAroundBikeAnnotation: NSObject
@property(retain, nonatomic) JYAroundBike *bike;
@end

@interface MAAnnotationContainerView

@end







%hook MAAnnotationContainerView
- (void)addAnnotationView:(id)arg1 { 
 %orig; 
 NSLog(@"addAnnotationView = %@  class = %@", arg1, [arg1 class]);
 // CKUserAnnoView   JYNearlyBikeAnnoView  JYAroundBikeAnnoView


 	if ([arg1 isKindOfClass:[%c(JYNearlyBikeAnnotation) class]]) {
         
        JYNearlyBikeAnnotation * a =  (JYNearlyBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }

    if ([arg1 isKindOfClass:[%c(JYAroundBikeAnnotation) class]]) {
         
        JYAroundBikeAnnotation * a =  (JYAroundBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }
}


- (void)addAnnotation:(id)arg1 { 
 %orig; 
 NSLog(@"addAnnotation = %@  class = %@", arg1, [arg1 class]);
 if ([arg1 isKindOfClass:[%c(JYNearlyBikeAnnotation) class]]) {
         
        JYNearlyBikeAnnotation * a =  (JYNearlyBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }

    if ([arg1 isKindOfClass:[%c(JYAroundBikeAnnotation) class]]) {
         
        JYAroundBikeAnnotation * a =  (JYAroundBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }

 // MAUserLocation    JYNearlyBikeAnnotation   JYAroundBikeAnnotation

} 


- (id)selectedAnnotation { 

 id   arg1 = %orig; 
 NSLog(@"selectedAnnotation = %@  class = %@", arg1, [arg1 class]);
 //HBLogDebug(@" = 0x%x", (unsigned int)r);  

 // r = JYAroundBikeAnnotation


if ([arg1 isKindOfClass:[%c(JYNearlyBikeAnnotation) class]]) {
         
        JYNearlyBikeAnnotation * a =  (JYNearlyBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }

    if ([arg1 isKindOfClass:[%c(JYAroundBikeAnnotation) class]]) {
         
        JYAroundBikeAnnotation * a =  (JYAroundBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }



    return arg1;
}

// - (void)bringSelectedAnnotationViewToFront { %log; %orig; }

- (BOOL)deselectAnnotation:(id)arg1 animated:(BOOL)arg2 { 
%log; BOOL r = %orig; 
NSLog(@"deselectAnnotation = %@  class = %@", arg1, [arg1 class]);
//HBLogDebug(@" = %d", r); 


if ([arg1 isKindOfClass:[%c(JYNearlyBikeAnnotation) class]]) {
         
        JYNearlyBikeAnnotation * a =  (JYNearlyBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }

    if ([arg1 isKindOfClass:[%c(JYAroundBikeAnnotation) class]]) {
         
        JYAroundBikeAnnotation * a =  (JYAroundBikeAnnotation *)arg1;
        JYAroundBike * bike = a.bike;
        NSLog(@"addAnnotationView   bike ---- bikeNo = %@ - iconType = %@ - images = %@ - parkIcon = %@ - parkIconPlus = %@ - thumbnail = %@", bike.bikeNo, bike.iconType, bike.images, bike.parkIcon, bike.parkIconPlus, bike.thumbnail);
    }


return r; 

// JYStartPointAnnotation  JYAroundBikeAnnotation  JYNearlyBikeAnnotation
}



%end
