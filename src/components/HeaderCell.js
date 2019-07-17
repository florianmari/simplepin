import React from 'react'
import { StyleSheet, Text, View } from 'react-native'
import PropTypes from 'prop-types'
import { color, padding, font, row } from '../style/style'

const s = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    height: row.medium,
    marginTop: padding.small,
    paddingHorizontal: padding.medium,
  },
  text: {
    color: color.gray4,
    fontSize: font.large,
    fontWeight: font.bold,
  },
})

export default class HeaderCell extends React.PureComponent {
  render() {
    return (
      <View style={[s.header, this.props.style]}>
        <Text style={s.text}>{this.props.text}</Text>
      </View>
    )
  }
}

HeaderCell.propTypes = {
  text: PropTypes.string.isRequired,
  style: PropTypes.object,
}
