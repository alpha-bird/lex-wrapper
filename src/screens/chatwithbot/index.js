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
import CommonWidgets from '@components/commonWidgets';

import { NativeModules } from 'react-native';
var BotManager = NativeModules.LexBotManager;

class ChatWithBot extends Component {
    constructor( props ) {
        super(props);

        this.state = {
            chatHistory : '',
            sendingString : '',
        }

        this.receivedMessage = this.receivedMessage.bind(this);
        this.receivedFromClient = this.receivedFromClient.bind(this);
    }

    receivedFromClient( msg ) {
        var history = this.state.chatHistory;
        history += ( 'Client : ' + msg + '\n' );
        this.setState({
            chatHistory : history
        });
    } 

    receivedMessage( msg ) {
        var history = this.state.chatHistory;
        history += ( 'Lex : ' + msg + '\n' );
        this.setState({
            chatHistory : history
        });
    }

    render() {
        return (
            <View style = {{ flex : 1 }}>
                <TextInput
                    multiline = { true }
                    editable = { false }
                    value = { this.state.chatHistory }
                    style = {{ flex : 4, margin : 1, marginTop : 20 ,borderWidth : 1, borderColor : 'black', fontSize : 15 }}
                    />
                <View style = {{ flex : 1, flexDirection : 'row', alignItems : 'center' }}>
                    <TextInput 
                        style = {{ flex : 8, height : '80%' , margin : 3,borderWidth : 1, borderColor : 'black' }}
                        value = { this.state.sendingString }
                        onChangeText = { (value) => { this.setState({
                            sendingString : value
                        })}}
                        />
                    <TouchableOpacity 
                        onPress = { () => {
                            BotManager.initAWSLexKit();
                            this.receivedFromClient(this.state.sendingString);
                            BotManager.sendToServer( this.state.sendingString, this.receivedMessage );
                            this.setState({
                               sendingString : ''  
                            });
                        }}
                        style = {{ flex : 2, alignItems : 'center', justifyContent : 'center' }}>
                        <Text>SEND</Text>
                    </TouchableOpacity>
                </View>
                <View style = {{ flex : 5 }}/>
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

export default connect(mapStateToProps,mapDispatchToProps)(ChatWithBot);