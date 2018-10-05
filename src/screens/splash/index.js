import React, { Component } from 'react';
import { Image, ActivityIndicator , View , Text, StyleSheet} from 'react-native';
import { connect } from 'react-redux';
import { responsiveHeight, responsiveWidth, responsiveFontSize } from 'react-native-responsive-dimensions';

import Utils from '@src/utils';
import {Images, Metrics, Colors} from '@themes';
import CommonWidgets from '@components/commonWidgets';

let netStateTimer;

class Splash extends Component {

  componentDidMount() {
    netStateTimer = setInterval(this.onTimer.bind(this), 1000);
     // this.gotoNext();
  }
  componentWillUnmount() {
    clearInterval(netStateTimer);
  }
  onTimer() {
    // if (this.props.globals.networkState) {
    clearInterval(netStateTimer);
    this.gotoNext();
    // }
    // CommonWidgets.showNetworkError();
  }

  async gotoNext() {
      clearInterval(netStateTimer);
      setTimeout(() => {
          this.props.navigation.dispatch(Utils.getResetAction('homeScreen'));
      }, 500);
  }

  render() {
    return (
        <View style= { { flex : 1, alignItems : 'center', justifyContent : 'center'}}>
            <Text>Splash Screen</Text>
        </View>
    );
  }
}

function mapDispatchToProps(dispatch) {
  console.log(dispatch);
  return {
    dispatch,
  };
}

function mapStateToProps(state) {
  return { globals : state.globals }
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash);
