import { StackNavigator } from 'react-navigation';
import Splash from '@splash';
import HomeScreen from '../src/screens/home';
import ChatWithBot from '../src/screens/chatwithbot';
import VoiceChatWithBot from '../src/screens/voicechatwithbot';

const AppNavigator = StackNavigator(
  {
    splash: { screen: Splash },
    homeScreen : { screen : HomeScreen },
    chatscreen : { screen : ChatWithBot },
    voicechatscreen : { screen : VoiceChatWithBot }
  },
  {
    initialRouteName: 'splash',
    navigationOptions: {
      header: null,
      cardStack: { gesturesEnabled: false },
    },

    headerMode: 'screen',
    lazyLoad: true,
  }
);

export default AppNavigator;
