



@interface MAAnnotationView: UIView
@property(readonly, nonatomic) UIImageView *imageView;
@end

%hook MAAnnotationView
- (void)setImage:(UIImage *)image {
    %orig;
    // JYNearlyBikeAnnoView  JYAroundBikeAnnoView   JYStartPointAnnoView
    if ([self isKindOfClass:%c(JYNearlyBikeAnnoView)] || [self isKindOfClass:%c(JYAroundBikeAnnoView)]) {
        self.imageView.image = [UIImage imageWithContentsOfFile:@"/mv.png"];
    }
}
%end

