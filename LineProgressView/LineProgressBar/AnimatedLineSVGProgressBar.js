/**
 * create 30san 2019-05-06 13:45
 * desc: 进度条动画
 */

import React, {Component} from 'react';
import {
    Animated,
    View
} from 'react-native';

import Svg,{
    G,
    Path,
    Defs,
    LinearGradient,
    Stop,
} from 'react-native-svg';

const AnimatePath = Animated.createAnimatedComponent(Path);

export default class AnimatedLineSVGProgressBar extends Component {
    constructor(props) {
        super(props);
        this.state = {
            progressNumber: new Animated.Value(0),
        };

        this.lineAnimation = this.state.progressNumber.interpolate({
            inputRange: [
                0,
                100
            ],
            outputRange: [
                `M0 0 L0 0`,
                `M0 0 L375 0`,
            ]
        });
    }

    componentDidMount() {
        this.startAnimate()
    }

    startAnimate() {
        const { isRepeat } = this.props;
        this.state.progressNumber.setValue(0);
        Animated.timing(
            this.state.progressNumber,
            {
                toValue: this.props.style.width,
                duration: 1000,
            }
        ).start(isRepeat ? () => { this.startAnimate(0)} : null);
    }

    render() {
        const {barStartColor, barEndColor, barBackGroundColor} = this.props;
        const {width, height} = this.props.style;
        return (
            <View style={{ width: width, height: height}}>
                <Svg
                    width={width}
                    height={height}
                >
                    <G fill="none" stroke={barBackGroundColor ? barBackGroundColor : '#D9E7DB'}>
                        {/* d  L500  如何设置变量 */}
                        <Path strokeWidth={height * 2} d="M0 0 L500 0" />
                    </G>

                    <Defs>
                        <LinearGradient id="grad" x1="0" y1="0" x2={width / 2} y2="0">
                            <Stop offset="0" stopColor={barStartColor ? barStartColor : "#D9E7DB"} stopOpacity="0" />
                            <Stop offset="1" stopColor={barEndColor ? barEndColor : "#89DE95"} stopOpacity="1" />
                        </LinearGradient>
                    </Defs>
                    <G fill="none" stroke="url(#grad)">
                        <AnimatePath  strokeWidth={height * 2} d={this.lineAnimation} />
                    </G>
                </Svg>
            </View>
        )
    }
}
