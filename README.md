# AreveaTV

## Version

1(1.19)

## Build and Runtime Requirements
* Xcode 11.5 or later
* iOS 10.0 or later
* OS X v10.15.5 or later

Please refre the following link to know how to install app on simulator or device using Xcode.

https://developer.apple.com/documentation/xcode/running_your_app_in_the_simulator_or_on_a_device

### Red 5 Pro iOS Stream Classes

We are using the files exists on the following path for handle single stream subscribe.

**/AreveaTV/AreveaTV/Stream Classes**

We are accessing the code from the following file.

**/AreveaTV/AreveaTV/Channels/StreamDetailVC.swift**

Method Names : **setLiveStreamConfig(),configureStreamView()**

### Additional Instructions: 
we got Red 5 Pro sample from the following link.
https://github.com/red5pro/streaming-ios


Eventhough we are using BaseTest directly, we are not using any Publisher methods.
Please observe **/AreveaTV/AreveaTV/Stream Classes/R5options.plist** file.  it has only **subscribe** params, but not **publish** params.

And Please observe **config()** method in **SubscribeTest.swift** and **getConfig()** method in **BaseTest.swift**, We are not using any publisher methods.

**SubscribeTest.swift** and **BaseTest.swift** are exists in the following path. **/AreveaTV/AreveaTV/Stream Classes**
