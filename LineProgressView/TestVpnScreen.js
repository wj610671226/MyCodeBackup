/**
 * create 30san 2019-04-10 14:22
 * desc: 测试vpn
 *
 * 需要使用到的库 "react-native-svg": "^9.4.0", "react-native-elements": "^1.1.0","react-native-vector-icons": "^6.4.2"
 *
 */

import React, {Component} from 'react';
import {
    StyleSheet,
    View,
    Button,
    Dimensions,
} from 'react-native';
import VpnConnectView from './VPNView/VpnConnectView';
const width = Dimensions.get('window').width;

const VPNICON_COLOR_FAIL = '#E4595C';
const VPNICON_COLOR_SUCCESS = '#43B63E';

const VPN_BACKGROUNDCOLOR_COLOR_FAIL = '#F9A4A4';
const VPN_BACKGROUNDCOLOR_COLOR_SUCCESS = '#89DE95';

export default class TestVpnScreen extends Component {

    constructor(props) {
        super(props);
        this.state = {
            connectState: '尚未连接',
            count: 0,
            account: '',
            password: '',

            vpnState: '正在连接VPN,请稍后...',
            vpnIcon: '',
            isShowVpnView: false,
            isAllowClick: false,
            vpnIconColor: '',
            isConnectingVpn: false, // 是否连接正在连接vpn
            vpnViewBackgroundColor: '#FFC6C6'
        }
    }

    render() {
        return (
            <View style={styles.container}>
                <View style={{margin: 50}}>
                    <Button title={"开始"} onPress={() => this.startConnect()}/>

                    <View style={{marginTop: 20}}>
                        <Button title={"结束"} onPress={() => this.stopConnect()}/>
                    </View>
                </View>
                {this.state.isShowVpnView ?
                    <VpnConnectView message={this.state.vpnState}
                                    containerStyle={{width: width, height: 40, alignItems: 'center', backgroundColor: this.state.vpnViewBackgroundColor}}
                                    iconName={this.state.vpnIcon}
                                    isAllowClick={this.state.isAllowClick}
                                    iconColor={this.state.vpnIconColor}
                                    isShowProcess={this.state.isConnectingVpn}
                                    onPressMessage={() => this.testClickMessage()}
                    /> : null}
            </View>
        )
    }

    testClickMessage() {
        alert('testClickMessage');
    }



    startConnect = async () => {
        this.setState({
            isShowVpnView: true,
            isConnectingVpn: true
        });

        this.timer = setInterval(() => {
            let count = this.state.count;
            count ++;
            console.log('startConnect count = ' + count);
            this.setState({
                count: count
            });
            if (count > 5) {
                this.timer && clearInterval(this.timer);
                this.setState({
                    vpnState: 'VPN连接成功',
                    vpnIcon: 'check-circle', // exclamation-circle   check-circle
                    vpnIconColor: VPNICON_COLOR_SUCCESS,
                    isConnectingVpn: false,
                    vpnViewBackgroundColor: VPN_BACKGROUNDCOLOR_COLOR_SUCCESS
                });
            }
        }, 1000);


        //
        // this.setState({
        //     vpnState: 'VPN连接失败，点击重试',
        //     vpnIcon: 'exclamation-circle',
        //     isAllowClick: true,
        //     vpnIconColor: VPNICON_COLOR_FAIL,
        //     isConnectingVpn: false,
        //     vpnViewBackgroundColor: VPN_BACKGROUNDCOLOR_COLOR_FAIL
        // });
    };

    stopConnect = async() => {
        this.setState({
            connectState: '断开成功',
            vpnState: '正在连接VPN,请稍后...',
            vpnIcon: '',
            isAllowClick: false,
            vpnIconColor: '',
            isShowVpnView: false,
            isConnectingVpn: false,
            vpnViewBackgroundColor: '#FFC6C6'
        });
    };

    componentWillUnmount() {
        this.timer && clearInterval(this.timer);
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    textInputStyle: {
        borderColor: 'red',
        borderWidth: 1,
        borderRadius: 5,
        marginTop: 5,
        marginBottom: 5
    },
    vpnViewStyle: {
        width: 375,
        height: 40,
        flexDirection: 'row',
        alignItems: 'center'
    },
    msgStyle: {
        marginLeft: 20
    },
});