/**
 * create 30san 2019-05-05 15:53
 * desc: vpn连接视图
 */

import React, {Component} from 'react';
import {TouchableOpacity, StyleSheet, Text, View} from 'react-native';
import {Icon} from "react-native-elements";
import PropTypes from "prop-types";
import AnimatedLineSVGProgressBar from '../LineProgressBar/AnimatedLineSVGProgressBar';



export default class VpnConnectView extends Component {

    static propTypes = {
        iconName: PropTypes.string,
        iconSize: PropTypes.number,
        iconColor: PropTypes.color,
        iconType: PropTypes.string,
        iconStyle: PropTypes.style,
        textStyle: PropTypes.style,
        message: PropTypes.string,
        connectStyle: PropTypes.style,
        onPressMessage: PropTypes.func,
        isAllowClick: PropTypes.bool,
        isShowProcess: PropTypes.bool,
    };

    static defaultProps = {
        iconName: '', // check-circle exclamation-circle
        iconSize: 26,
        iconColor: '#FF5151', // #E4595C  #43B63E
        iconType: 'font-awesome',
        onPressMessage: null,
        isAllowClick: false,
        isShowProcess: false
    };

    render() {
        const {iconName, iconSize, iconColor, iconType, iconStyle, textStyle, message, containerStyle, isAllowClick} = this.props;
        const {width, height} = containerStyle;
        return (
            <View style={containerStyle ? containerStyle : styles.container}>

                {this.props.isShowProcess ? <AnimatedLineSVGProgressBar
                    style={{
                        height: height,
                        width: width,
                    }}
                    isRepeat={true}/> : null}

                <TouchableOpacity style={[styles.messageContainer, {height: height}]} activeOpacity={1}
                                  onPress={isAllowClick ? () => this.clickMessage() : null}
                >
                    {!this.props.isShowProcess ? <Icon name={iconName} size={iconSize} color={iconColor} type={iconType}
                                                      iconStyle={iconStyle ? iconStyle : styles.iconStyle}/> : null}
                    <Text style={textStyle ? textStyle : styles.textStyle}>{message}</Text>
                </TouchableOpacity>
            </View>
        )
    }

    clickMessage() {
        this.props.onPressMessage && this.props.onPressMessage();
    }
}

const styles = StyleSheet.create({
    container: {
        height: 40,
        backgroundColor: '#FFC6C6',
        flexDirection: 'row',
        alignItems: 'center',
    },
    iconStyle: {
        marginLeft: 15,
    },
    textStyle: {
        marginLeft: 15,
        color: '#333030',
        fontSize: 16,
    },
    messageContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        position: 'absolute',
        left: 0,
        top: 0,
    }
});