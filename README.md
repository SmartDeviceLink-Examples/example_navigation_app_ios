# example_navigation_app_ios

This example application is to be used as a reference for developers looking to use the [SmartDeviceLink](https://github.com/smartdevicelink/sdl_ios) platform with their mobile navigation app.

## App Setup

### Initial Setup
After cloning this project, you will need to run a `pod install` from the root directory and open the newly created `.xcworkspace` file.

### Setting Permissions

If you are using this app with production or test hardware it is very likely that this app will not work due to OEMs restricting permissions for video streaming apps. Therefore you will need to set an **app name** and **app ID** with the correct permissions. Additionally, you will need set a [MapBox](https://www.mapbox.com/) access token in order to use the map.

To set the MapBox access token, app name, and app ID of this project, please follow the steps below.

### Setting App Keys

1. Navigate to the `keys.plist` file in the Xcode directory.
2. Create three key values named `AppName`, `AppID`, and `MGLMapboxAccessToken` of type `String`
3. Set the values to the appropriate key.

Note that, at minimum, the `MGLMapboxAccessToken` must be set in order to use the app without SDL.


### Setting Connection Type

By default, the app will attempt to connect via `iAP` after launch. If you would like to set up a `TCP` connection, navigate to the `SDLAppConstants.swift` file and change the `connectionType` to `.tcp`. Additionally, you will need to set the correct `ipAddress` and `port` values as well.

For more information about connection types, please [refer to our guide](https://smartdevicelink.com/en/guides/iOS/getting-started/connecting-to-an-infotainment-system/).

### App Stream Types

Given that MapBox uses OpenGL for rendering, `layer` and `viewBeforeScreenUpdates` render options will not currently work with this app. Additional map options will be added in future updates to make these options usable.

On first launch, the app will have a `offScreen` Stream Type and `viewAfterScreenUpdates` Render Type. These values can be changed by accessing the Menu button on the mobile device (note that the SDL implementation of this menu button is used as the [custom SDL menu](https://smartdevicelink.com/en/guides/iOS/video-streaming-for-navigation-apps/menus/)).

You cannot change these values while the app is connected to production or test hardware. If the app is currently searching for an SDL connection, you must tap STOP SEARCHING in order to reset the current connection. Once your desired Render and Streaming types are set, press the START button.
