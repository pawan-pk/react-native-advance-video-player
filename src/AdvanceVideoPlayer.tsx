import { type FC } from 'react';
import type { ViewProps, StyleProp, ViewStyle } from 'react-native';
import AdvanceVideoPlayerViewNativeComponent, {
  type NativeVLCMedia,
} from './AdvanceVideoPlayerViewNativeComponent';

type VLCPlayerEvent = {
  error: string;
};

type MediaTrack = {
  id: number;
  name: string;
};

interface MediaMetaData {
  title: string;
  artist: string;
  albumArtist: string;
  album: string;
  genre: string;
  trackNumber: number;
  discNumber: number;
  artworkURL: string;
}

type VLCMedia = {
  titles: string[];
  audioTracks: Array<MediaTrack>;
  subtitleTracks: Array<MediaTrack>;
  videoSize: {
    width: number;
    height: number;
  };
  duration: number;
  aspectRatio: string;
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
  audioTrack?: number;
  subtitleTracks?: number;
  // Events
  onMediaMetaData?: (media: MediaMetaData) => void;
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
  onMediaMetaData,
  ...rest
}) => {
  const onLoadMedia = (media: NativeVLCMedia) => {
    const audioTracksIndexes = media.audioTracksIndexes.split(',');
    const audioTracksNames = media.audioTracksNames.split(',');
    const audioTracks = audioTracksIndexes.map((value, index) => ({
      id: Number(value),
      name: audioTracksNames[index]!,
    }));
    const subtitleTracksIndexes = media.subtitleTracksIndexes.split(',');
    const subtitleTracksNames = media.subtitleTracksNames.split(',');
    const subtitleTracks = subtitleTracksIndexes.map((value, index) => ({
      id: Number(value),
      name: subtitleTracksNames[index]!,
    }));

    onLoad?.({
      titles: media.titles.split(','),
      audioTracks: audioTracks,
      subtitleTracks: subtitleTracks,
      videoSize: media.videoSize,
      duration: media.duration,
      aspectRatio: media.aspectRatio,
    });
  };

  return (
    <AdvanceVideoPlayerViewNativeComponent
      onLoad={(e) => onLoadMedia(e.nativeEvent)}
      onError={(e) => onError?.(e.nativeEvent)}
      onBuffer={(e) => onBuffer?.(e.nativeEvent)}
      onProgress={(e) => onProgress?.(e.nativeEvent)}
      onMediaMetaData={(e) => onMediaMetaData?.(e.nativeEvent)}
      {...rest}
    />
  );
};

export default AdvanceVideoPlayer;
