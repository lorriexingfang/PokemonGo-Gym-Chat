# PokemonGo Gym Club: Everything you want to know about Pokemon Gyms

<table width="100%">
    <tr>
        <td width="100"><img src="http://zifacdn.oss-cn-hangzhou.aliyuncs.com/PokegymGo.png" width="72px" height="72px" alt="RaidCDN logo"/></td>
        <td>Pokegmon Gym Club is the first open source mobile app (both for iOS and Android) which works as a forum for nearby Pokemon gyms. It is a community where trainers can find their teammates and go to the Pokemon battlefield for a fight. Pokemon lovers will make friends here by uploading their battle snapshots, chatting with other trainers, and go for a battle together.
    </td>
    </tr>
</table>


## 0. Index

1. [Description](#1-description)
2. [Implementation](#2-implementation)

## 1. Description

Discover and explore your nearby Pokemon Gyms.


FEATURES

-- Forum for nearby gyms

-- Meet teammates and inviting them for a battle/training

-- Share how many pokemons you defeated by uploading snapshots

-- Chat with trainers and hangout with them

## 2. Implementation

Android:

Installing Prerequisites(for Android):
1. Install JDK.
2. Install Android Studio.
3. Install Meteor
4. Set necessary environment variables.

All the three steps above can be done by using Ubuntu Make:
1. Add the Ubuntu Make ppa:
    ```
	$ sudo add-apt-repository ppa:ubuntu-desktop/ubuntu-make
	$ sudo apt-get update
	```

2. Install Ubuntu Make:
    ```
	$ sudo apt-get install ubuntu-make
	```

Use Ubuntu Make to install Android Studio and all dependencies:
    ```
	$ umake android
	```

3. Install Meteor from [**Meteor Installation] (Install Meteor (https://www.meteor.com/install)
   ```
   $ curl https://install.meteor.com/ | sh
   ```

4. Set environment variables:
Add these lines on ~/.bashrc:
	# Android
	```
	export ANDROID_HOME="/home/<username>/Android/Sdk"
	export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
	```

After these steps, we change to the directory of our project and add Cordova platform:
    ```
    $ cd PokemonGo-Chat/pokemonchat-mobile
	$ meteor add-platform android
	```

Pokegmon Gym Club should be run on Meteor 1.2.1. Just run the app by:
    ```
	$ meteor run android-device --release 1.2.1
	```

Then we can run the app on the emulator by:
	$ meteor run android

Or on the phone that has been connected to the computer by a USB cable:
    ```
	$ meteor run android-device
	```
=================================================================================================================
Possible Errors and Solutions:
1. When running the app on the phone:
	name: 'CordovaError',
	message: 'Failed to deploy to device, no devices found.',

Solution:
	Make sure the phone is connected to the computer.To check if the computer can detect the phone, run:
	    ```
		$ adb devices
		```
	Then we need to enable the phone's On-device Developer Options:
		https://developer.android.com/studio/run/device.html#developer-device-options
		
2. When staring the emulator, the process is stuck in "Staring app on Android Emulator":

Solution:
	Run "$ meteor run android --verbose" to see the detailed requirements, here for my:
		emulator: WARNING: Increasing RAM size to 1024MB
		emulator: WARNING: VM heap size set below hardware specified minimum of 32MB
		emulator: WARNING: Setting VM heap size to 256MB
		sh: 1: glxinfo: not found
		emulator: ERROR: x86_64 emulation currently requires hardware acceleration!
		Please ensure KVM is properly installed and usable.
		CPU acceleration status: /dev/kvm is not found: VT disabled in BIOS or KVM kernel module not loaded
		
		Here we can create a new emulator with the proper parameters, but as for my system, the KVM is not supported.
		
3. When adding Cordova platform:
		Your system does not yet seem to fulfil all requirements to build apps for Android.
		status of the requirements:                   
		✓ Java JDK                                    
		✓ Android SDK                                 
		✗ Android target: Please install Android target: "android-22".

			Hint: Open the SDK manager by running: /home/bo/Android/Sdk/tools/android
			You will require:
			1. "SDK Platform" for android-22
			2. "Android SDK Platform-tools (latest)
			3. "Android SDK Build-tools" (latest)
		✓ Gradle           
	
Solution:
	Simply run "$ /home/<username>/Android/Sdk/tools/android",and selected the SDK Platfoem for the corresponding API version and the latest other two.
	Delete 'android' under <project>/.meteor/local/platforms.
	run "$ meteor add-platform android"
	
4. When running the app on the phone:
		Exception in thread "main" java.lang.UnsupportedClassVersionError:
		com/android/dx/command/Main : Unsupported major.minor version 52.0
	
Solution:
	The issue is because of Java version mismatch. Referring to the Wikipedia Java Class Reference : J2SE 8 = 52.The error regarding the unsupported major.minor version is because during compile time we are using a higher JDK and a lower JDK during runtime.
	Run "$ java --version" to see the JDK version.
	Generally, if we use Umake, the default JDK version is 1.7 but we need JDK 1.8.
	To update the JDK version, run: 
	    ```
		$ sudo add-apt-repository ppa:webupd8team/java
		$ sudo apt-get update
		$ sudo apt-get install oracle-java8-installer
		```
		
5. When running the app on the phone:
			% Error during processing of action! Attempting to revert...
			% Error during processing of action! Attempting to revert...
			% Error during processing of action! Attempting to revert...                    
			% Failed to install 'cordova-plugin-crosswalk-webview':Error: Uh oh!

Solution:
    Pokegmon Gym Club should be run on Meteor 1.2.1. Just run the app by:
    ```
	$ meteor run android-device --release 1.2.1
	```