/*
	Copyright 2013-2014, JUMA Technology

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/


var exec = require('cordova/exec');
var platform = require('cordova/platform');
var interval_index = null;

/**
 * Provides access to wifi on the device.
 */
var wifi = {
	
	getConnectedWifiInfo: function(successFunc,errorFunc){
		cordova.exec(successFunc,errorFunc,"BCWifi","getConnectedWifiInfo",[]);
	},
	
};
module.exports = wifi;

