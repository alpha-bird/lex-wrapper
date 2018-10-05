import React, { Component } from 'react';
import { View, 
    Text, 
    StyleSheet, 
    Image, 
    TouchableHighlight,
    TouchableOpacity,
    TextInput,
    Button
} from 'react-native';
import { connect } from 'react-redux';
import { responsiveHeight, responsiveWidth, responsiveFontSize } from 'react-native-responsive-dimensions';
import {Images, Metrics, Colors, Styles} from '@themes';
import utils from '../../utils';

class Home extends Component {
    constructor( props ) {
        super(props);

    }

    render() {
        return (
            <View style = {{ flex : 1, flexDirection : 'column', justifyContent : 'center', alignItems : 'center' }}>
                <TouchableOpacity 
                style = {{ margin : 30 }}
                onPress = { () => {
                    this.props.navigation.dispatch(utils.getResetAction('chatscreen'));
                }}>
                    <Text>Chat with LexBot</Text>
                </TouchableOpacity>

                <TouchableOpacity onPress = { () => {
                    this.props.navigation.dispatch(utils.getResetAction('voicechatscreen'));
                }}>
                    <Text>Voicechat with LexBot</Text>
                </TouchableOpacity>
            </View>
        );
    }
}

function mapDispatchToProps(dispatch) {
    return {
        dispatch,
    };
}

function mapStateToProps(state) {
    return { app_state : state };
}

export default connect(mapStateToProps,mapDispatchToProps)(Home);