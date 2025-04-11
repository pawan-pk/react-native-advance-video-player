import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type {
  HostComponent,
  ViewProps,
  StyleProp,
  ViewStyle,
} from 'react-native';

interface NativeProps extends ViewProps {
  url?: string;
}

type NativeEvent<T> = {
  nativeEvent: T;
};

type VLCPlayerEvent = {
  message?: string;
};

type NativeEventsProps = {
  onError?: (event: NativeEvent<VLCPlayerEvent>) => void;
};

export interface AdvanceVideoPlayerProps {
  style?: StyleProp<ViewStyle>;
}

export default codegenNativeComponent<NativeProps>(
  'AdvanceVideoPlayerView'
) as HostComponent<NativeProps & NativeEventsProps>;
