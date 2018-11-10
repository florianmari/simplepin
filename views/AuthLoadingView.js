import React from 'react'
import {View} from 'react-native'
import Storage from 'app/util/Storage'

export default class AuthLoadingView extends React.Component {
  constructor(props) {
    super(props)
    this.initialView()
  }

  initialView = async () => {
    const apiToken = await Storage.apiToken()
    this.props.navigation.navigate(apiToken ? 'App' : 'Auth')
  }

  render() {
    return <View />
  }
}
