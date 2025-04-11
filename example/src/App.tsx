import { StyleSheet } from 'react-native';
import AdvanceVideoPlayerView from 'react-native-advance-video-player';

export default function App() {
  return (
    <AdvanceVideoPlayerView
      url="http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
      style={styles.container}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
