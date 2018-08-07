
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
{
    JYAroundBike *_bike;
}
@end

%hook JYAroundBikeAnnotation
//- (void)setBike:(JYAroundBike *)bike { 
//	%log; %orig; 
//}
//- (JYAroundBike *)bike { 
//	%log; JYAroundBike * r = %orig; HBLogDebug(@" = %@", r); return r;
//}
- (id)initWith:(JYAroundBike *)arg1 { 
	NSLog(@"initWith   arg1 = %@", arg1);
	//NSLog(@"initWith   arg1  class = %@", [arg1 class]);


	//id bike = MSHookIvar<JYAroundBike *>(self, "_bike");
	//NSLog(@"initWith   bike = %@", bike);

 
	NSLog(@"initWith    %@ -  %@ -  %@  - %@ -  %@ -  %@ - %@ -  %@ -  %@ - %@ -  %@ -  %@ - %@", arg1.lat, arg1.lng, arg1.parkGuid, arg1.parkIcon, arg1.parkIconPlus, arg1.parkName, arg1.parkRadius, arg1.parkTip, arg1.parkType, arg1.price, arg1.radius, arg1.thumbnail, arg1.time);

	//%log;
	 id r = %orig; 
	//HBLogDebug(@" = %@", r);
	  return r; 
}
%end
