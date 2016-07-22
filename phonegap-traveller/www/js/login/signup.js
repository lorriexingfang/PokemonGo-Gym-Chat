var signup = {
	signup:function(){
		var userName = $("#userName").val();
		if(userName==""){
			alert("请输入昵称...");
			return;
		}
		remote.utils.setParam("userName", userName);
		index_nav.enter_bblist_slideup(false);
	}
}