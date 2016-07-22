var partner_comment = {
	submit_comment : function() {
		var text = $("#commentTextarea").val();
		if (text == "") {
			alert("请填写评论");
			return;
		}
		var json = JSON.parse(remote.utils.getParam("current_date_partner"));
	    var comObj = {
	    		"_id":"xxxxx",
	    		"userid":"xxxxxx",
	    		"userLogo":"xxxxxx.jpg",
	    		"createTime":new Date().getTime(),
	    		"userName":remote.utils.getParam("userName"),
	    		"content":text};
		json.comment.push(comObj);
		var _id = json._id;
		json._id=undefined;
		$.ajax({
			url : remote.website + "/pick_msg/"+_id+"/",
			context : document.body,
			dataType : "json",
			type : "PUT",
			data : JSON.stringify(json),
			contentType : "application/json",
			success : function(e) {
				history.back();
				console.info(e);
			}
		});
	}
}
