Meteor.startup(function () {
	getUserLanguage = function() {
		var lang;
		lang = void 0;
		// 检测浏览器语言
		// 非	IE
		lang = navigator.language;
		// IE
		if (!lang){
			lang = navigator.browserLanguage	
		}
		lang = lang.substr(0, 2);
		return lang;
	}

});