/**
 * create 30san 2019-05-06 09:54
 * desc:
 */

import React, {Component} from 'react';
import {
    StyleSheet,
    View,
    Dimensions,
    Text
} from 'react-native';
import AnimatedLineSVGProgressBar from './LineProgressBar/AnimatedLineSVGProgressBar';
const width = Dimensions.get('window').width;

export default class LineProgressBarPage extends Component {

    // 动画  timing 随时间变化而执行动画

    /*

    Animated.decay()以指定的初始速度开始变化，然后变化速度越来越慢直至停下。
    Animated.spring()提供了一个简单的弹簧物理模型.
    Animated.timing()使用easing 函数让数值随时间动起来。


    *
    * */
    render() {
        return (
            <View style={styles.container}>
                <AnimatedLineSVGProgressBar
                    style={{
                        height: 40,
                        width: width
                    }}
                    isRepeat={true}
                />
            </View>
        )
    }
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    }
});