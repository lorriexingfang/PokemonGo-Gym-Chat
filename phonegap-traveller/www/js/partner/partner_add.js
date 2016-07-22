var partner_add = {
	submitData : function() {
		var line = $("#edit_line").val();
		var start_time = $("#edit_start_time").val();
		var days = $("#edit_days").val();
		var sth = $("#edit_say_sth").val();
		if (line == "") {
			alert("请填入路线");
			return false;
		}
		if (start_time == "") {
			alert("请填入出发时间");
			return false;
		}
		if (days == "") {
			alert("请填入旅行天数");
			return false;
		}
		if (sth == "") {
			alert("请填入搭伙信息");
			return false;
		}
		
		
		var s = {
			   "userid": "xxxxxx",
			   "userName": remote.utils.getParam("userName"),
			   "userLogo": "",
			   "userCity": "上海",
			   "line": line.split(" "),
			   "startTime": start_time,
			   "days": days,
			   "tags": [
			       "自驾",
			       "写生"
			   ],
			   "description": sth,
			   "createTime": new Date().getTime(),
			   "like": 0,
			   "comment":[]
			};
		$.ajax({
			url : remote.website+"/pick_msg",
			context:document.body,
			dataType:"json",
			type:"POST",
			data:JSON.stringify(s),
			contentType:"application/json",
			success : function(e) {
				history.back();
				console.info(e);
			}
		});
		// $.post('http://192.168.2.11:5984/pick_msg/',{"title":"There is
		// Nothing Left to Lose","artist":"Foo
		// Fighters"},function(e){alert(e);});
	}
}