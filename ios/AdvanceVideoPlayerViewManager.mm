#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "AdvanceVideoPlayer-Swift.h"

#import "RCTBridge.h"
#import "RCTConvert+MediaTrack.h"

@interface AdvanceVideoPlayerViewManager : RCTViewManager
@end

@implementation AdvanceVideoPlayerViewManager

RCT_EXPORT_MODULE(AdvanceVideoPlayerView)

- (UIView *)view
{
  return [[AdvanceVideoPlayer alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onBuffer, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(rate, double)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(volume, double)
RCT_EXPORT_VIEW_PROPERTY(paused, BOOL)
RCT_EXPORT_VIEW_PROPERTY(resizeMode, NSString)
RCT_EXPORT_VIEW_PROPERTY(audioTrack, int)
RCT_EXPORT_VIEW_PROPERTY(textTrack, int)

@end
