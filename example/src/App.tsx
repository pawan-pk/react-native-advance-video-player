import { View, StyleSheet } from 'react-native';
import { AdvanceVideoPlayerView } from 'react-native-advance-video-player';

export default function App() {
  return (
    <View style={styles.container}>
      <AdvanceVideoPlayerView color="#32a852" style={styles.box} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
