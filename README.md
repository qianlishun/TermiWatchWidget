# Terminal Watch Widget
[中文说明](https://github.com/qianlishun/TermiWatchWidget/wiki/中文说明)

Terminal Watch Widget Face for Apple Watch.

![Watch Face](Screenshots/Watch_Preview.png)

For devices running watchOS 10 or higher.

Due to the fact that the new version of watchOS no longer supports app persistence,   

here we use widgets to achieve a Watch Face similar to the Terminal effect.

Thanks for TermiWatch https://github.com/kuglee/TermiWatch/

# Future
 Use **WeatherKit** to obtain weather information. **WeatherKit** only supports **paid developer accounts**.  
 Next, I will add other methods to obtain weather data.

# How to install

## Prerequisites && Adding a developer account to Xcode
  Refer to TermiWatch's tutorial
  - *TermiWatcht* https://github.com/kuglee/TermiWatch/blob/master/README.md

  1. For each of the 3 **targets** replece *void* in the **Bundle Identifier** field with the name of your developer account. (The name of your Apple ID without the *@xxxx.com*.)
  ![Xcode Setting1](Screenshots/Xcode_Settings1.png)      
  1. Change the project's team:
      1. Select the **Signing & Capabilities** tab:    
      1. For each of the 3 **targets** change the **Team** to your team. (Usually this is your name.)  
  1. Manually replace bundle identifiers:
        1. Select **Xcode** menu -> **Find** -> **Find and Replace in Project…**.
        1. In the **Text** field type *void* (Maybe others like *xxx* in com.xxx.TermiWatch)
        1. In the **With** field type the name of your developer account. (The name of your Apple ID without the @xxxx.com.)
        1. Click the **Replace All** button.
  1. If there is an error in WeatherKit or HealthKit, please set Capability
  .![Xcode Setting2](Screenshots/Xcode_Settings2.png)


## Installing the app
  1. Plug your phone into your computer.
  1. Unlock your phone and trust your computer.
  1. Select **Xcode** menu -> **Product** -> **Destination**. At the **Device** section select your phone.
  1. Select **Xcode** menu -> **Product** -> **Run**.
  1. Wait for the app to install on your phone.
  1. Go to **Settings** -> **General** -> **Profiles & Device Management** on your phone to trust the app.
  1. Install the watchOS app from the **Watch** app.

## Watch Settings
  1. Open Face Gallery Find and add Modular Duo Face  
  ![Duo Modular](Screenshots/Watch_Setting1.png)
  2. Set Complications, Set these 3 options  
    <img src="Screenshots/Watch_Setting2.png" width="40%" height="auto" />
  4. Find TerminalWatchWidget, And set Top Left(Circular), Middle(Weather), Bottom(Health)  
    <img src="Screenshots/Watch_Setting3.png" width="40%" height="auto" />

