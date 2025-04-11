#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

@interface AdvanceVideoPlayerViewManager : RCTViewManager
@end

@implementation AdvanceVideoPlayerViewManager

RCT_EXPORT_MODULE(AdvanceVideoPlayerView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(url, NSString)

@end
