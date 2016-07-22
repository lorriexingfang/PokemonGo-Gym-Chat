/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var remote = {
	author : 'Tim',
	version : '1.0',
	website : 'http://64.193.227.36:5984'
	}
remote.utils = {
	setParam : function(name, value) {
		localStorage.setItem(name, value)
	},
	getParam : function(name) {
		return localStorage.getItem(name)
	}
}
remote.isValidateNULL = function(val) {
	if (!val)
		val = "";
	return val;
}


$(document).bind("mobileinit", function() {
	// 跨域设置
	$.support.cors = true;
	$.mobile.allowCrossDomainPages = true;
	// 干掉默认转场效果
	$.mobile.defaultPageTransition = "none";
});
//var root_ = "/Users/zhanglv/Documents/Code/traveller/phonegap-traveller/www/pages";
//var root_ = "/Users/zhanglv/Documents/Code/traveller/platforms/android/assets/www/pages";
//var root_ = "file:///home/tim/Workspace/traveller/phonegap-traveller/www/pages"
var root_ = "file:///android_asset/www/pages";

var index_nav = {
	//小黑板
	enter_bblist_slideup : function(reverse) {
			$.mobile.changePage(root_ + "/blackboard/bbList.html", {
				transition:"slideup",
				"reverse":reverse
			});
	},
	enter_bblist : function(reverse) {
			$.mobile.changePage(root_ + "/blackboard/bbList.html", {
				transition:"slide",
				"reverse":reverse
			});
		},
	enter_bblist_l : function() {
		this.enter_bblist(true);
	},
	//搭伙
	enter_partner : function(reverse) {
		$.mobile.changePage(root_ + "/partner/partner.html", {
			transition : "slide",
			"reverse":reverse
		});
	},
	enter_partner_l : function() {
		this.enter_partner(true);
	},
	enter_partner_r : function() {
		this.enter_partner(false);
	},
	//发消息中心
	enter_sendingCenter : function() {
		$.mobile.changePage(root_ + "/sendingCenter/center.html", {
			transition : "slideup"
		});
	},
	//当地人
	enter_local_service : function(reverse) {
		$.mobile.changePage(root_ + "/localService/localCenter.html", {
			transition : "slide",
			"reverse":reverse
		});
	},
	enter_local_l: function() {
		this.enter_local_service(true);
	},
	enter_local_r : function() {
		this.enter_local_service(false);
	},
	//我的
	enter_mine : function(reverse) {
		$.mobile.changePage(root_ + "/mine/mineCenter.html", {
			transition : "slide",
			"reverse":reverse
		});
	},
	enter_mine_r : function() {
		this.enter_mine(false);
	},
	enter_signup:function(){
		$.mobile.changePage(root_ + "/login/signup.html", {
			transition : "slide",
			"reverse":false
		});
	}
};

var app = {
	// Application Constructor
	initialize : function() {
		this.bindEvents();
	},
	// Bind Event Listeners
	//
	// Bind any events that are required on startup. Common events are:
	// 'load', 'deviceready', 'offline', and 'online'.
	bindEvents : function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	// deviceready Event Handler
	//
	// The scope of 'this' is the event. In order to call the 'receivedEvent'
	// function, we must explicitly call 'app.receivedEvent(...);'
	onDeviceReady : function() {
		app.receivedEvent('deviceready');
	},
	// Update DOM on a Received Event
	receivedEvent : function(id) {
		var parentElement = document.getElementById(id);
		var listeningElement = parentElement.querySelector('.listening');
		var receivedElement = parentElement.querySelector('.received');
		listeningElement.setAttribute('style', 'display:none;');
		receivedElement.setAttribute('style', 'display:block;');

		console.log('Received Event: ' + id);
	}
};

$(document).on("pageshow","#page_index",function(){
	var userName = remote.utils.getParam("userName");
	if(remote.isValidateNULL(userName)==""){
		index_nav.enter_signup();
	}else{
		index_nav.enter_bblist_l();
	}
});
