#import "RCTConvert+MediaTrack.h"

@implementation RCTConvert (MediaTrack)

+ (MediaTrack *)MediaTrack:(id)json {
    MediaTrack *mediaTrack = [MediaTrack new];
    json = [self NSDictionary:json];
    mediaTrack.type = json[@"type"];
    mediaTrack.value = json[@"value"];
    return mediaTrack;
}

RCT_ARRAY_CONVERTER(MediaTrack)

@end

