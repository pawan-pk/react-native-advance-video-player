import { type FC } from 'react';
import type { ViewProps, StyleProp, ViewStyle } from 'react-native';
import AdvanceVideoPlayerViewNativeComponent from './AdvanceVideoPlayerViewNativeComponent';

type VLCPlayerEvent = {
  error: string;
};

// type MediaTrack = {
//   id: number;
//   name: string;
// };

type VLCMedia = {
  subtitle: string;
  // audioTracks: ReadonlyArray<MediaTrack>;
  // textTracks: ReadonlyArray<MediaTrack>;
  videoSize: {
    width: number;
    height: number;
  };
  duration: number;
  aspectRatio: number;
};

export type MediaProgress = {
  currentTime: number;
  remainingTime: number;
  position: number;
};

export interface AdvanceVideoPlayerProps extends ViewProps {
  url?: string;
  rate?: number;
  muted?: boolean;
  volume?: number;
  paused?: boolean;
  style?: StyleProp<ViewStyle>;
  aspectRatio?: number;
  selectedAudioTrack?: number;
  selectedTextTrack?: number;
  // Events
  onLoad?: (media: VLCMedia) => void;
  onEnd?: () => void;
  onError?: (error: VLCPlayerEvent) => void;
  onBuffer?: (value: { buffering: boolean }) => void;
  onProgress?: (progress: MediaProgress) => void;
}

const AdvanceVideoPlayer: FC<AdvanceVideoPlayerProps> = ({
  onLoad,
  onError,
  onBuffer,
  onProgress,
  ...rest
}) => {
  return (
    <AdvanceVideoPlayerViewNativeComponent
      onLoad={(e) => onLoad?.(e.nativeEvent)}
      onError={(e) => onError?.(e.nativeEvent)}
      onBuffer={(e) => onBuffer?.(e.nativeEvent)}
      onProgress={(e) => onProgress?.(e.nativeEvent)}
      {...rest}
    />
  );
};

export default AdvanceVideoPlayer;
