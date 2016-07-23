### Build locally Prerequisites(for iOS)

1\. Need to have a Macbook with Xcode installed

2\. Install Meteor

#Steps

Install Meteor from [Meteor Installation] (https://www.meteor.com/install)
   ```
   $ curl https://install.meteor.com/ | sh
   ```

It will ask you to also install nodejs and mongodb. You may need to use [Homebrew] (http://brew.sh/) to install those packages


After these steps, we change to the directory of our project and add Cordova platform:

    $ cd PokemonGo-Chat/pokemonchat-mobile
	$ meteor add-platform ios

Pokegmon Gym Club should be run on Meteor 1.2.1. Just run the app by:

	$ meteor run android-device --release 1.2.1

Then we can run the app on the emulator by:

	$ meteor run ios

Or on the iphone that has been connected to the computer by a USB cable:

	$ meteor run ios-device