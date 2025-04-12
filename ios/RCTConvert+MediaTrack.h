#import <React/RCTConvert.h>

#import "MediaTrack.h"

@interface RCTConvert (MapboxNavigation)

+ (MediaTrack *)MediaTrack:(id)json;

typedef NSArray MediaTrackArray;
+ (MediaTrackArray *)MediaTrackArray:(id)json;

@end
