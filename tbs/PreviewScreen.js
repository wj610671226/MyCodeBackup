/**
 * create 30san 2019-03-19 09:56
 * desc:
 */

import React, {Component} from 'react';
import {StyleSheet, Text, View, Dimensions, ActivityIndicator} from 'react-native';
import CommonHeader from '../../../components/CommonHeader';

import { requireNativeComponent } from "react-native";
const TbsPreviewView = requireNativeComponent("TbsPreviewView");

const {width, height} = Dimensions.get('window');

export default class PreviewScreen extends Component {

    constructor(props) {
        super(props);
        this.state = {
            isLocadingTbsView: false,
            localPath: ""
        }
    }

    render() {
        return (
            <View style={styles.container}>
                <CommonHeader
                    title={"预览界面"}
                    left={true}
                    navigation={this.props.navigation}
                />
               <View style={{alignItems: 'center', justifyContent: 'center',flex: 1}}>
                   <Text onPress={() => this.showTbsView()}>显示</Text>
                   {
                       this.state.isLocadingTbsView ? <TbsPreviewView style={styles.previewViewStyle}
                                                                      localPath={this.state.localPath}
                       /> : <ActivityIndicator size="large" color="#0000ff" />
                   }
               </View>
            </View>
        )
    }

    showTbsView() {
        const { navigation } = this.props;
        const localPath = navigation.getParam("localPath" , "默认路径");
        this.setState({
            isLocadingTbsView: true,
            localPath: localPath
        });
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    previewViewStyle: {
        width: width,
        height: 500,
    }
});