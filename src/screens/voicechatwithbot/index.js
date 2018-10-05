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
import { NativeModules } from 'react-native';
var voiceBot = NativeModules.VoiceChatManager;

class VoiceChat extends Component {
    constructor( props ) {
        super(props);
        this.state = {
            chatDisabled : false,
            recordingStatus : 'Start Voice Chat',
            inputString : '',
            outPutString : ''
        }
    }

    render() {
        return (
            <View style = {{ flex : 1, flexDirection : 'column', justifyContent : 'center', alignItems : 'center' }}>
                <TouchableOpacity
                    style = {{ width : 200, height : 30, borderWidth : 1, borderColor : 'black', justifyContent : 'center', alignItems : 'center'}}
                    disabled = { this.state.chatDisabled }
                    onPress = { () => { 
                        if( this.state.recordingStatus === 'Start Voice Chat' ) {
                            voiceBot.setStartingCallBack( ( result ) => {
                                this.setState({
                                    recordingStatus : 'In progress',
                                    chatDisabled : true
                                });
                            });
    
                            voiceBot.startVoiceChat( (input, output) => {
                                this.setState({
                                        inputString : input,
                                        outPutString : output,
                                        chatDisabled : false,
                                        recordingStatus : 'Start Voice Chat'
                                    });
                                }); 
                        }
                    }}
                    >
                    <Text>{ this.state.recordingStatus }</Text>
                </TouchableOpacity>
                <Text style = {{ margin : 30 }}> { this.state.inputString }</Text>
                <Text>{this.state.outPutString}</Text>
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

export default connect(mapStateToProps,mapDispatchToProps)(VoiceChat);