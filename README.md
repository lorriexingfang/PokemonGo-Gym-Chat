# PokemonGo Gym Club: Everything you want to know about Pokemon Gyms

<table width="100%">
    <tr>
        <td width="100"><img src="http://zifacdn.oss-cn-hangzhou.aliyuncs.com/PokegymGo.png" width="72px" height="72px" alt="RaidCDN logo"/></td>
        <td>Pokegmon Gym Club is the first open source mobile app (both for iOS and Android) which works as a Pokemon fans' club which contains all information about nearby Pokemon gyms. It is a community where trainers can find their teammates and go to the Pokemon battlefield for a fight. Pokemon lovers will make friends here by uploading their battle snapshots, chatting with other trainers, and go for a battle together.
    </td>
    </tr>
</table>


## 0. Index

1. [Description](#1-description)
2. [Build](#2-build)
3. [Implementation](#3-implementation)
4. [Tips](#4-tips)

## 1. Description

Discover and explore your nearby Pokemon Gyms.


###FEATURES

-- A Pokemon fans' club which contains all information about nearby Pokemon gyms

-- Meet teammates and inviting them for a battle/training

-- Share how many pokemons you defeated by uploading snapshots

-- Chat with trainers and hangout with them

## 2. Build

- [Android Guide](docs/android/README.md)

- [iOS Guide](docs/ios/README.md)

## 3. Implementation

The whole project can be divided into client and server sides. In the following I will explain how to implement both sides. But before that, I suppose you have already set up your own server.

### Server address and File storage service url/keys

Currently we are using Aliyun's ECS/OSS/CDN service. You can choose other services (Amazon S3, etc) based on our architecture. I will show how to modify the code if you also want to use Aliyun's service. 

1\. Replace the "http://localhost.com" with your own server address

To make it run as a real application, you should have a real server to do the backend stuffs. After you have it, please grep "http://localhost.com" and replace it with your current server IP or Domain name.


2\. For uploading file's server address, please grep "var cdnFileName" and replace with your file server address

3\. If you are using AWS server, please grep "AWSAccessKeyId" and replace the current password with your password.
Again, since  we are using Aliyun OSS service, you have to change the code a little bit to use S3 as the file storage service. 

4\. Grep "var uri = encodeURI" and replace the url with your Amazon S3/Baidu BCS service's url.

5\. More specifically, for replacing the API/Secret keys of your file storage service, please check ./pokemonchat-mobile/server/servermethod_register.coffee and look at:

"getAliyunWritePolicy", 
"getS3WritePolicy",
and "getBCSSigniture"

Replace the keys with your own keys.

### App/Facebook/Wechat's ID/keys

Sometime you will use Facebook/Wechat/Twitter Login in this application. We support this feature but you have to use your own ID and keys:

1\. Under ./PokemonGo-Chat/pokemonchat-mobile, there is a mobile-config.js file. Check it out and replace the current one with yours.

### For monitoring the server

We use [Kadira] (https://kadira.io/) to monitor server performance. It's not necessary if you have other ways of monitoring the whole service.

1\. The setups for Kadira is here: ./pokemonchat-mobile/server/kadira.coffee . Replace it with your Kadira account.

### Push notification keys

iOS:

There are .pem files under ./pokemonchat-mobile/private/ and ./web-pokemonchat/private/ . Replace them with your own .pem files to enable the push notification feature.

Android:

We use [jpush] (https://www.jiguang.cn/) to enable push notification on Android. Grep "jpush" in the code to replace them with yoru own service.

Above are probably everything you will do for replacing setups with your own.

### Deploy service on server

We use [mup] (https://github.com/arunoda/meteor-up) to deploy the service on server. To do it, please:

1\. Please upload your /PokemonGo-Chat/pokemonchat-mobile folder to your server

2\. Modify /PokemonGo-Chat/pokemonchat-mobile/mup.json with your own setups.

3\. Run

	$mup setup
	$mup deploy

to deploy your server.

If you follow everything I have mentioned above, your will have your real Pokemon Gym Club up and running in the real world.

## 4. Tips

1\. You can delete ./pokemonchat-mobile/client/scripts/disable_console_log.js and ./pokemonchat-mobile/client/scripts/disable_hot_code_push.js when you develop in your local environment. It will help to

a) Print out the console log
b) Enable the hotcode push feature. So your modification will be applied immediately and you do not have to stop and rerun the code.