


@interface JYAroundBike
	@property(copy, nonatomic) NSString *lat; // @synthesize lat=_lat;
	@property(copy, nonatomic) NSString *lng; // @synthesize lng=_lng;
	@property(copy, nonatomic) NSString *parkGuid; // @synthesize parkGuid=_parkGuid;
	@property(copy, nonatomic) NSString *parkIcon; // @synthesize parkIcon=_parkIcon;
	@property(copy, nonatomic) NSString *parkIconPlus; // @synthesize parkIconPlus=_parkIconPlus;
	@property(copy, nonatomic) NSString *parkName; // @synthesize parkName=_parkName;
	@property(retain, nonatomic) NSNumber *parkRadius; // @synthesize parkRadius=_parkRadius;
	@property(copy, nonatomic) NSString *parkTip; // @synthesize parkTip=_parkTip;
	@property(retain, nonatomic) NSNumber *parkType; // @synthesize parkType=_parkType;
	@property(copy, nonatomic) NSString *price; // @synthesize price=_price;
	@property(copy, nonatomic) NSString *radius; // @synthesize radius=_radius;
	@property(retain, nonatomic) NSString *thumbnail; // @synthesize thumbnail=_thumbnail;
	@property(copy, nonatomic) NSString *time; // @synthesize time=_time;
@end

@interface JYAroundBikeAnnotation
@property(retain, nonatomic) JYAroundBike *bike;
@end

%hook JYAroundBikeAnnoView

//- (void)setCalloutView:(JYTextCalloutView *)calloutView { %log; %orig; }
//- (JYTextCalloutView *)calloutView { %log; JYTextCalloutView * r = %orig; HBLogDebug(@" = %@", r); return r; }
//- (id)iconForType:(id)arg1 { 
 //	id r = %orig; 
//	NSLog(@"iconForType   arg1 = %@", arg1);
///	NSLog(@"iconForType   arg1  class = %@", [arg1 class]);
//	NSLog(@"iconForType   r = %@", r);
//	return r; 
//}

- (id)initWithAnnotation:(JYAroundBikeAnnotation *)arg1 reuseIdentifier:(NSString *)arg2 {
    id r = %orig;
    //NSLog(@"initWithAnnotation   arg1 = %@, arg2 = %@", arg1, arg2);
	//NSLog(@"initWithAnnotation   arg1 class = %@    arg2 class = %@", [arg1 class], [arg2 class]);
	//NSLog(@"initWithAnnotation   r = %@", r);

	JYAroundBike * bike = arg1.bike;
	// NSLog(@"bike = %@", bike);

	NSLog(@"initWithAnnotation    %@ -  %@ -  %@  - %@ -  %@ -  %@ - %@ -  %@ -  %@ - %@ -  %@ -  %@ - %@", bike.lat, bike.lng, bike.parkGuid, bike.parkIcon, bike.parkIconPlus, bike.parkName, bike.parkRadius, bike.parkTip, bike.parkType, bike.price, bike.radius, bike.thumbnail, bike.time);
	return r; 
 }

//- (void)removeObserver:(id)arg1 forKeyPath:(id)arg2 { %log; %orig; }
//- (void)setSelected:(BOOL)arg1 { %log; %orig; }
//- (void)setSelected:(BOOL)arg1 animated:(BOOL)arg2 { %log; %orig; }

%end
