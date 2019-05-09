/**
 * create 30san 2019-05-06 09:54
 * desc:
 */
import React, {Component} from 'react';
import {
    StyleSheet,
    View,
    ART
} from 'react-native';

const {
    Surface,
    Group,
    Shape,
    LinearGradient,
    Path,
} = ART;

export default class LineProgressBar extends Component {

    static defaultProps = {
        barColor: new LinearGradient({
                '0': 'red',
                '1': 'blue'
            },
            '', "", 100,  ''),
        backgroundPath: new Path(),
        abovePath: new Path(),
        progressNumber: 0,
        progressTotal: 100,
        backgroundLineHeight: 2,
        aboveLineHeight: 2,
        backgroundLineColor: '#EAEAEB',
        aboveLineColor: '#3D8A52'
    };

    constructor(props) {
        super(props);
        this.state = {
            aboveLineColor: '#667733',
            centerViewText: '0'
        };
    }

    componentDidMount() {
        const {style, progressTotal, progressNumber,barStartColor, barEndColor} = this.props;
        this.setState({
            backgroundPath: this.getBackGroundPath(style.width, style.height),
            abovePath: this.getAboveGroundPath(style.width / progressTotal * progressNumber, style.height),
            barColor: this.getLinearGradient(barStartColor, barEndColor)
        })

    }

    componentWillReceiveProps(nextProps) {
        if (nextProps != this.props) {
            this.setState({
                backgroundPath: this.getBackGroundPath(nextProps.style.width, nextProps.style.height),
                abovePath: this.getAboveGroundPath(nextProps.style.width / nextProps.progressTotal * nextProps.progressNumber, nextProps.style.height, 6),
                barColor: this.getLinearGradient(nextProps.barStartColor, nextProps.barEndColor),
            })
        }
    }

    getLinearGradient = (startColor, endColor) => {
        return(
            new LinearGradient({
                    '0': startColor,
                    '1': endColor
                },
                '', "", this.props.style.width,  ''
            )
        )
    };

    getBackGroundPath = (width, height) => {
        return(
            // new Path()
            //     .moveTo(height / 2 + strokeWidth,  strokeWidth)
            //     .lineTo(width - height / 2 - strokeWidth, strokeWidth)
            //     .arcTo(width - strokeWidth, height/ 2 + strokeWidth)
            //     .arcTo(width - strokeWidth - height / 2, height + strokeWidth)
            //     .lineTo(height / 2 + strokeWidth, height + strokeWidth)
            //     .arcTo(strokeWidth, height / 2 + strokeWidth)
            //     .arcTo(height / 2 + strokeWidth, strokeWidth)
            //     .close()

            new Path()
                .moveTo(0,  0)
                .lineTo(width, 0)
                .lineTo(width, height)
                .lineTo(0, height)
                .close()
        )
    };

    getAboveGroundPath = (width, height) => {
        if (width == 0){
            return new Path();
        }
        return(
            new Path()
                .moveTo(0,  0)
                .lineTo(width, 0)
                .lineTo(width, height)
                .lineTo(0, height)
                .close()
        )
    };


    render() {
        return (
            <View {...this.props}>
                <Surface width={this.props.style.width} height={this.props.style.height}>
                    <Group>
                        <Shape
                            d={this.state.backgroundPath}
                            fill={this.props.barBackGroundColor ? this.props.barBackGroundColor : '#D9E7DB'}
                        />
                        <Shape
                            d={this.state.abovePath}
                            fill={this.state.barColor}
                            strokeWidth={this.props.strokeWidth}
                            stroke={this.props.strokeColor}
                        />
                    </Group>
                </Surface>
            </View>
        )
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F4F4F4'
    },
})
