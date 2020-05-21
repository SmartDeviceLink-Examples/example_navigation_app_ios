# example_navigation_app_ios

This example application is to be used as a reference for developers looking to use the [SmartDeviceLink](https://github.com/smartdevicelink/sdl_ios) platform with their mobile navigation app.

You will need a [MapBox](https://www.mapbox.com/) access token and an app name & ID with the correct permissions if you plan to use this app in an SDL environment. To set the access token, app name, and app ID of this project, please follow the steps below.

Setting App Keys

1. Create a `keys.plist` file in the project.
2. Create three key values named `AppName`, `AppID`, and `MGLMapboxAccessToken` of type `String`
3. Set the values to the appropriate key.

Note that, at minimum, the `MGLMapboxAccessToken` must be set in order to use the app.
